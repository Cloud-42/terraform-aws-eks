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
  name = var.lc_name

  ebs_optimized = var.ebs_optimized
  iam_instance_profile {
    arn  = var.eks_worker_iam_instance_profile_arn
    name = var.eks_worker_iam_instance_profile_name
  }

  image_id = var.eks_worker_ami
  key_name = var.eks_worker_ssh_key_name

  monitoring {
    enabled = var.eks_worker_monitoring
  }

  network_interfaces {
    associate_public_ip_address = var.eks_worker_associate_public_ip_address
  }

  vpc_security_group_ids = ["${var.eks_worker_security_group_ids}"]

  tag_specifications {
    resource_type = "instance"

    tags = var.tags
  }

  user_data = "${base64encode(data.template_file.userdata.rendered)}"
}

# ----------------------------------------
# Workers ASG
# ----------------------------------------
resource "aws_autoscaling_group" "this" {
  desired_capacity    = var.eks_worker_desired_capacity
  max_size            = var.eks_worker_max_size
  min_size            = var.eks_worker_min_size
  name                = "${var.eks_cluster_name}-${var.eks_worker_group_name}"
  vpc_zone_identifier = [var.eks_worker_subnet_ids]

  mixed_instances_policy {

    launch_template {
      launch_template_specification {
        launch_template_id = "${aws_launch_template.template.id}"
      }
      override {
        instance_type = var.eks_worker_instance_type
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
    value               = "${var.eks_cluster_name}-${var.eks_worker_group_name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.eks_cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }
}

