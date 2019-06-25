variable "eks_cluster_name" {
  type = string
}

variable "vpc_id" {
}

variable "management_ip" {
  description = "Management IP which is granted access to the control plane. Default is a place holder"
}

