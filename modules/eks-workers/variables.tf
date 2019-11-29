variable "eks_worker_monitoring" {
  description = "If true, the launched EC2 instance will have detailed monitoring enabled."
  default     = "false"
}
variable "eks_api_endpoint" {}
variable "eks_api_ca" {}
variable "eks_worker_ami" {}
variable "eks_cluster_name" {
  type = string
}
variable "eks_worker_ssh_key_name" {
  type = string
}
variable "eks_worker_ami_name" {
  type    = string
  default = "amazon-eks-node-"
}
variable "eks_worker_desired_capacity" {
  type    = string
  default = "3"
}
variable "eks_worker_min_size" {
  type    = string
  default = "2"
}
variable "eks_worker_max_size" {
  type    = string
  default = "4"
}
variable "eks_worker_instance_profile" {
  type = string
}
variable "eks_worker_group_name" {
  type = string
}
variable "eks_worker_sg_id" {
  type = string
}
variable "eks_worker_subnet_ids" {
}
variable "eks_worker_associate_public_ip_address" {
  type    = string
  default = "false"
}
variable "region" {
  type = string
}
variable "eks_worker_iam_instance_profile_arn" {}
variable "eks_worker_security_group_ids" {
  description = "A list of security group IDs to associate with."
}
variable "eks_worker_iam_instance_profile_name" {}
variable "eks_worker_health_check_type" {
  default = "EC2"
}
variable "eks_worker_on_demand_base_capacity" {}
variable "eks_worker_on_demand_percentage_above_base_capacity" {}
variable "eks_worker_spot_allocation_strategy" {}
variable "eks_worker_instance_type" {}
