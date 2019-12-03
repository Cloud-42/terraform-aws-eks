output "cluster_iam_role_arn" {
  description = "Cluster IAM Role ARN"
  value       = aws_iam_role.cluster.arn
}

output "node_iam_role_arn" {
  description = "Node IAM Role ARN"
  value       = aws_iam_role.node.arn
}

output "node_iam_role_name" {
  description = "Node IAM Role Name"
  value       = aws_iam_instance_profile.node_profile.name
}


output "node_iam_profile_arn" {
  description = "Nodes IAM Instance Profile"
  value       = aws_iam_instance_profile.node_profile.arn
}
