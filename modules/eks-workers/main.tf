# ----------------------------------------
# Userdata
# ----------------------------------------
data "template_file" "userdata" {
  template = <<USERDATA
#!/bin/bash -xe
/etc/eks/bootstrap.sh --apiserver-endpoint ${var.eks_api_endpoint} --b64-cluster-ca ${var.eks_api_ca} ${var.eks_cluster_name}
USERDATA
}
# ----------------------------------------
# Workers launch template 
# ----------------------------------------
resource "aws_launch_template" "template" {

  name_prefix = var.eks_worker_lc_name
  capacity_reservation_specification {
    capacity_reservation_preference = var.eks_worker_capacity_reservation_preference
  }
  credit_specification {
    cpu_credits = var.eks_worker_cpu_credits
  }
  ebs_optimized = var.eks_worker_ebs_optimized
  image_id      = var.eks_worker_ami
  key_name      = var.eks_worker_ssh_key_name
  iam_instance_profile {
    arn = var.eks_worker_iam_instance_profile_arn
  }
  monitoring {
    enabled = "${var.eks_worker_monitoring}"
  }
  vpc_security_group_ids = ["${var.eks_worker_security_group_ids}"]

  tag_specifications {
    resource_type = "instance"

    tags = "${
      map(
        "Name", "kubernetes.io-${var.eks_cluster_name}-node",
        "kubernetes.io/cluster/${var.eks_cluster_name}", "owned",
      )
    }"
  }
  user_data = "${base64encode(data.template_file.userdata.rendered)}"

  lifecycle {
    create_before_destroy = true
  }
}
# ----------------------------------------
# Workers ASG
# ----------------------------------------
resource "aws_autoscaling_group" "this" {
  desired_capacity    = var.eks_worker_desired_capacity
  max_size            = var.eks_worker_max_size
  min_size            = var.eks_worker_min_size
  name                = "${var.eks_cluster_name}-${var.eks_worker_group_name}"
  vpc_zone_identifier = var.eks_worker_subnet_ids

  mixed_instances_policy {

    launch_template {
      launch_template_specification {
        launch_template_id = "${aws_launch_template.template.id}"
        version = "${aws_launch_template.template.latest_version}"
      }
   
   #
   # Dynamic block to allow for multiple instance types
   # 
   dynamic "override" {
        for_each = var.eks_worker_instance_type
           content {
             instance_type = override.value["instance_type"]
       }
    }
    }

    instances_distribution {
      on_demand_base_capacity                  = var.eks_worker_on_demand_base_capacity
      on_demand_percentage_above_base_capacity = var.eks_worker_on_demand_percentage_above_base_capacity
      spot_allocation_strategy                 = var.eks_worker_spot_allocation_strategy
    }
  }

  health_check_type = var.eks_worker_health_check_type
  tag {
    key                 = "Name"
    value               = "kubernetes.io-cluster-${var.eks_cluster_name}-worker-node"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.eks_cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }
}

