output "cluster_sg_id" {
  description = "SG ID for cluster SG"
  value       = aws_security_group.cluster.id
}

output "node_sg_id" {
  description = "SG ID for Nodes SG"
  value       = aws_security_group.node.id
}

