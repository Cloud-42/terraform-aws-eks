variable "management_ip" {
  description = "Management IP which is granted access to the control plane. Default is a place holder"
}

variable "endpoint_private_access" {
  default = "false"
}

variable "endpoint_public_access" {
  default = "true"
}

variable "subnet_ids" {
}

variable "kubernetes_version" {
  default = "1.14"
}

variable "eks_cluster_name" {
}

variable "vpc_id" {
}
#
# EKS Worker Vars
#
variable "region" {}
variable "eks_worker_ssh_key_name" {}
variable "eks_worker_subnet_ids" {}
variable "eks_worker_group_name" {}
variable "eks_worker_ami" {}
variable "eks_worker_on_demand_base_capacity" {}
variable "eks_worker_on_demand_percentage_above_base_capacity" {}
variable "eks_worker_instance_type" {}
#variable "eks_worker_iam_instance_profile_arn" {}
#variable "eks_worker_iam_instance_profile_name" {}
