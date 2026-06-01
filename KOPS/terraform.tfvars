# మీ values ఇక్కడ మార్చండి — అంతే!
# మిగతా అన్నీ Terraform automatic గా చేస్తుంది

cluster_name         = "mycluster.k8s.local"
region               = "ap-south-1"
state_bucket_name    = "my-kops-state-store-2024"   # ← unique పేరు పెట్టండి
master_instance_type = "t3.medium"
node_instance_type   = "t3.medium"
node_count           = 2
master_count         = 1
kubernetes_version   = "1.28.0"
availability_zones   = ["ap-south-1a", "ap-south-1b"]
environment          = "dev"
