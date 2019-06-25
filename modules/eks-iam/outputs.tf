output "cluster_iam_role_arn" {
  description = "Cluster IAM Role ARN"
  value       = aws_iam_role.cluster.arn
}

output "node_iam_role_arn" {
  description = "Node IAM Role ARN"
  value       = aws_iam_role.node.arn
}

output "node_instance_profile_name" {
  description = "Nodes IAM Instance Profile"
  value       = aws_iam_instance_profile.node_profile.name
}
