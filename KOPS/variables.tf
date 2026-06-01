variable "cluster_name" {
  description = "Kops Kubernetes cluster name"
  type        = string
  default     = "mycluster.k8s.local"
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "ap-south-1"
}

variable "state_bucket_name" {
  description = "S3 bucket name for Kops state (globally unique గా ఉండాలి)"
  type        = string
  default     = "my-kops-state-store-2024"
}

variable "master_instance_type" {
  description = "Master node EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "node_instance_type" {
  description = "Worker node EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "node_count" {
  description = "Worker nodes ఎన్ని కావాలి"
  type        = number
  default     = 2
}

variable "master_count" {
  description = "Master nodes count"
  type        = number
  default     = 1
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28.0"
}

variable "availability_zones" {
  description = "AWS Availability Zones"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "environment" {
  description = "Environment"
  type        = string
  default     = "dev"
}
