variable "management_cidr" {
  description = "CIDR range which is granted access to the control plane. Usually the VPC CIDR range or similar. Not to be confused with public_access_cidrs. "
}
variable "endpoint_private_access" {
  description = "Enable or Disable private access point"
  default     = "false"
}
variable "endpoint_public_access" {
  description = "Enable or Disable public access point"
  default     = "true"
}
variable "subnet_ids" {
  description = "Subnet Ids into which the EKS control plane will be deployed"
}
variable "kubernetes_version" {
  description = "Kubernetes version"
  default     = "1.14"
}
variable "eks_cluster_name" {
  description = "Cluster name"
}
variable "vpc_id" {
  description = "ID of the VPC to use"
}
variable "log_retention_in_days" {
  description = "Log retention in days"
  default     = "14"
}
variable "enabled_cluster_log_types" {
  description = "Enabled log types. https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html"
  default     = ["api", "authenticator", "controllerManager", "scheduler"]
}
variable "public_access_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks that can access the public endpoint when it is enabled"
  default     = ["0.0.0.0/0"]
}
#
# EKS Worker Vars
#
variable "region" {
  description = "AWS Region"
}
variable "eks_worker_ssh_key_name" {
  description = "Default ssh key to use for worker nodes"
}
variable "eks_worker_subnet_ids" {
  description = "Subnet IDs to place worker nodes in"
}
variable "eks_worker_group_name" {
  description = "EKS worker nodes group name"
}
variable "eks_worker_ami" {
  description = "AMI ID for worker nodes"
}
variable "eks_worker_on_demand_base_capacity" {
  description = "Minimum amount of desired capacity that must be fulfilled by on-demand instances"
}
variable "eks_worker_on_demand_percentage_above_base_capacity" {
  description = "Percentage split between on-demand and Spot instances above the base on-demand capacity"
}
variable "eks_worker_instance_type" {
  description = "ec2 instance type for worker nodes"
}
variable "eks_worker_desired_capacity" {
  description = "Desired number of EKS Worker nodes"
  type        = string
  default     = "2"
}
variable "eks_worker_min_size" {
  description = "Minimum number of EKS Worker nodes"
  type        = string
  default     = "2"
}
variable "eks_worker_max_size" {
  description = "Maximum number of EKS Worker nodes"
  type        = string
  default     = "6"
}
