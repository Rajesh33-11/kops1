terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
      # SSH Key automatically generate చేయడానికి
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
      # Files locally save చేయడానికి
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
      # Kops CLI commands run చేయడానికి
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = "Kops-Kubernetes"
    }
  }
}
