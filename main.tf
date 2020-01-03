# -----------------------------------------------
# Declare sub-modules
# -----------------------------------------------
module "eks-iam" {
  source = "./modules/eks-iam"

  eks_cluster_name = var.eks_cluster_name
}
module "eks-security" {
  source = "./modules/eks-security"

  management_ip    = var.management_ip
  eks_cluster_name = var.eks_cluster_name
  vpc_id           = var.vpc_id
}
module "eks-workers" {
  source = "./modules/eks-workers"

  region           = var.region
  eks_cluster_name = var.eks_cluster_name

  # LC/ASG Settings
  eks_worker_lc_name                  = "${var.eks_cluster_name}-workers-"
  eks_worker_ssh_key_name             = var.eks_worker_ssh_key_name
  eks_worker_subnet_ids               = var.eks_worker_subnet_ids
  eks_worker_group_name               = var.eks_worker_group_name
  eks_worker_ami                      = var.eks_worker_ami
  eks_worker_iam_instance_profile_arn = module.eks-iam.node_iam_profile_arn
  eks_worker_security_group_ids       = module.eks-security.node_sg_id

  # Userdata Vars
  eks_api_endpoint = aws_eks_cluster.this.endpoint
  eks_api_ca       = aws_eks_cluster.this.certificate_authority[0].data

  eks_worker_on_demand_base_capacity                  = var.eks_worker_on_demand_base_capacity
  eks_worker_on_demand_percentage_above_base_capacity = var.eks_worker_on_demand_percentage_above_base_capacity
  eks_worker_instance_type                            = var.eks_worker_instance_type
}
# -----------------------------------------------
# Control Plane
# -----------------------------------------------
resource "aws_eks_cluster" "this" {
  depends_on = [aws_cloudwatch_log_group.eks]
  name       = var.eks_cluster_name
  role_arn   = module.eks-iam.cluster_iam_role_arn
  version    = var.kubernetes_version

  vpc_config {
    subnet_ids              = var.subnet_ids
    security_group_ids      = [module.eks-security.cluster_sg_id]
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
  }
  enabled_cluster_log_types = var.enabled_cluster_log_types
}

# LogGroup
resource "aws_cloudwatch_log_group" "eks" {
  name              = "/aws/eks/${var.eks_cluster_name}/cluster"
  retention_in_days = var.log_retention_in_days
}
