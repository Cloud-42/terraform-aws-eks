output "endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.this.certificate_authority[0].data
}

output "node_sg_id" {
  value = module.eks-security.node_sg_id
}

