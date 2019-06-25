# ----------------------------------------
# Userdata
# ----------------------------------------
locals {
  node_userdata = <<USERDATA
#!/bin/bash -xe
/etc/eks/bootstrap.sh --apiserver-endpoint ${var.eks_api_endpoint} --b64-cluster-ca ${var.eks_api_ca} ${var.eks_cluster_name}
USERDATA
}

# ----------------------------------------
# Workers LC
# ----------------------------------------
resource "aws_launch_configuration" "eksworkers" {
  associate_public_ip_address = var.eks_worker_public_ip_enable
  iam_instance_profile = var.eks_worker_instance_profile
  image_id = var.eks_worker_ami
  instance_type = var.eks_worker_instance_type
  key_name = var.eks_worker_ssh_key_name
  name_prefix = "${var.eks_cluster_name}-${var.eks_worker_group_name}"
  security_groups = [var.eks_worker_sg_id]
  user_data_base64 = base64encode(local.node_userdata)

  root_block_device {
    volume_type = "gp2"
    volume_size = 50
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ----------------------------------------
# Workers ASG
# ----------------------------------------
resource "aws_autoscaling_group" "this" {
  desired_capacity = var.eks_worker_desired_capacity
  launch_configuration = aws_launch_configuration.eksworkers.id
  max_size = var.eks_worker_max_size
  min_size = var.eks_worker_min_size
  name = "${var.eks_cluster_name}-${var.eks_worker_group_name}"
  vpc_zone_identifier = [var.eks_worker_subnet_ids]

  tag {
    key = "Name"
    value = "${var.eks_cluster_name}-${var.eks_worker_group_name}"
    propagate_at_launch = true
  }

  tag {
    key = "kubernetes.io/cluster/${var.eks_cluster_name}"
    value = "owned"
    propagate_at_launch = true
  }
}

