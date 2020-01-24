variable "eks_cluster_name" {
  type = string
}
variable "vpc_id" {
}
variable "management_cidr" {
  description = "CIDR range which is granted access to the control plane"
}
