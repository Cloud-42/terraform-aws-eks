variable "eks_api_endpoint" {}
variable "eks_api_ca" {}
variable "eks_worker_ami"{}

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

variable "eks_worker_instance_type" {
  type    = string
  default = "t3.medium"
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

variable "eks_worker_public_ip_enable" {
  type    = string
  default = "false"
}

variable "region" {
  type = string
}

