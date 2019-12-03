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
variable "log_retention_in_days" {
  description = "Log retention in days"
  default = "14"
}
variable "enabled_cluster_log_types" {
  description = "Enabled log types. https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html"
  default = ["api", "authenticator", "controllerManager", "scheduler"]
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
