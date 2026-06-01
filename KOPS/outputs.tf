# terraform apply తర్వాత ఇవి screen మీద కనిపిస్తాయి

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = var.cluster_name
}

output "state_store_url" {
  description = "Kops State Store S3 URL"
  value       = "s3://${var.state_bucket_name}"
}

output "ssh_private_key_path" {
  description = "SSH Private Key — Nodes కి SSH చేయడానికి"
  value       = "${path.module}/kops-ssh-key.pem"
}

output "validate_command" {
  description = "Cluster status check"
  value       = "kops validate cluster --name ${var.cluster_name} --state s3://${var.state_bucket_name}"
}

output "get_nodes_command" {
  description = "Nodes చూడడానికి"
  value       = "kubectl get nodes"
}

output "ssh_to_node_command" {
  description = "Node కి SSH చేయడానికి"
  value       = "ssh -i ${path.module}/kops-ssh-key.pem ubuntu@<NODE-IP>"
}

output "delete_cluster_command" {
  description = "Cluster delete చేయడానికి (bill తప్పించుకోవడానికి!)"
  value       = "terraform destroy"
}
