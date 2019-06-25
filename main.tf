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

  region                      = var.region
  eks_cluster_name            = var.eks_cluster_name
  eks_worker_sg_id            = module.eks-security.node_sg_id
  eks_worker_instance_profile = module.eks-iam.node_instance_profile_name

  # LC/ASG Settings
  eks_worker_ssh_key_name = var.eks_worker_ssh_key_name
  eks_worker_subnet_ids   = var.eks_worker_subnet_ids
  eks_worker_group_name   = var.eks_worker_group_name
  eks_worker_ami          = var.eks_worker_ami
 
  # Userdata Vars
  eks_api_endpoint            = aws_eks_cluster.this.endpoint
  eks_api_ca                  = aws_eks_cluster.this.certificate_authority[0].data
}


# -----------------------------------------------
# Control Plane
# -----------------------------------------------

resource "aws_eks_cluster" "this" {
  name     = var.eks_cluster_name
  role_arn = module.eks-iam.cluster_iam_role_arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = split(",", var.subnet_ids)
    security_group_ids      = [module.eks-security.cluster_sg_id]
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
  }
}

