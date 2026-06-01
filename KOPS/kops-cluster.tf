# ─────────────────────────────────────────────────────
# Kops Cluster — పూర్తిగా Automatic గా Create అవుతుంది
# మీరు manually ఏమీ చేయక్కర్లేదు!
#
# Flow:
#   1. Public key file write చేయడం
#   2. kops create cluster  → S3 లో config save
#   3. kops update cluster  → EC2 instances launch
#   4. kops validate        → Ready అయ్యే వరకు wait
#   5. kubeconfig export    → kubectl ready
# ─────────────────────────────────────────────────────

# ─────────────────────────────────────────────────────
# Step 1: Kops Cluster Config S3 లో Save చేయడం
# ─────────────────────────────────────────────────────
resource "null_resource" "kops_create" {
  depends_on = [
    aws_s3_bucket_versioning.kops_state,        # S3 ready అయిన తర్వాత
    aws_s3_bucket_public_access_block.kops_state,
    aws_key_pair.kops,                           # SSH key ready అయిన తర్వాత
    local_file.public_key,                       # Public key file ready అయిన తర్వాత
    aws_iam_role_policy_attachment.kops_policies # IAM ready అయిన తర్వాత
  ]

  triggers = {
    # ఏదైనా మారితే cluster recreate అవుతుంది
    cluster_name   = var.cluster_name
    node_count     = var.node_count
    node_size      = var.node_instance_type
    master_size    = var.master_instance_type
    k8s_version    = var.kubernetes_version
    bucket         = var.state_bucket_name
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "=================================================="
      echo " Step 1: Kops Cluster Config Create చేస్తున్నాం..."
      echo "=================================================="

      kops create cluster \
        --name=${var.cluster_name} \
        --state=s3://${var.state_bucket_name} \
        --zones=${join(",", var.availability_zones)} \
        --node-count=${var.node_count} \
        --node-size=${var.node_instance_type} \
        --master-size=${var.master_instance_type} \
        --master-count=${var.master_count} \
        --kubernetes-version=${var.kubernetes_version} \
        --networking=calico \
        --topology=public \
        --ssh-public-key=${path.module}/kops-ssh-key.pub \
        --cloud=aws \
        --yes

      echo "Config S3 లో save అయింది!"
    EOT

    environment = {
      AWS_DEFAULT_REGION = var.region
      KOPS_STATE_STORE   = "s3://${var.state_bucket_name}"
    }
  }

  # terraform destroy చేసినప్పుడు cluster delete అవుతుంది
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      echo "==> Cluster delete చేస్తున్నాం..."
      kops delete cluster \
        --name=${self.triggers.cluster_name} \
        --state=s3://${self.triggers.bucket} \
        --yes
      echo "==> Cluster deleted!"
    EOT
  }
}

# ─────────────────────────────────────────────────────
# Step 2: EC2 Instances Launch చేయడం
# ─────────────────────────────────────────────────────
resource "null_resource" "kops_update" {
  depends_on = [null_resource.kops_create]

  triggers = {
    kops_create_id = null_resource.kops_create.id
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "=================================================="
      echo " Step 2: EC2 Instances Launch చేస్తున్నాం..."
      echo "=================================================="

      kops update cluster \
        --name=${var.cluster_name} \
        --state=s3://${var.state_bucket_name} \
        --yes

      echo "Instances launch అయ్యాయి! Wait చేస్తున్నాం..."
    EOT

    environment = {
      AWS_DEFAULT_REGION = var.region
      KOPS_STATE_STORE   = "s3://${var.state_bucket_name}"
    }
  }
}

# ─────────────────────────────────────────────────────
# Step 3: Cluster Ready అయ్యే వరకు Wait చేయడం
# ─────────────────────────────────────────────────────
resource "null_resource" "kops_validate" {
  depends_on = [null_resource.kops_update]

  triggers = {
    kops_update_id = null_resource.kops_update.id
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "=================================================="
      echo " Step 3: Cluster Ready అవ్వడానికి Wait చేస్తున్నాం"
      echo " (10-15 minutes పడుతుంది...)"
      echo "=================================================="

      kops validate cluster \
        --name=${var.cluster_name} \
        --state=s3://${var.state_bucket_name} \
        --wait 20m

      echo "Cluster Ready!"
    EOT

    environment = {
      AWS_DEFAULT_REGION = var.region
      KOPS_STATE_STORE   = "s3://${var.state_bucket_name}"
    }
  }
}

# ─────────────────────────────────────────────────────
# Step 4: kubeconfig Automatically Export చేయడం
# ─────────────────────────────────────────────────────
resource "null_resource" "kops_kubeconfig" {
  depends_on = [null_resource.kops_validate]

  triggers = {
    kops_validate_id = null_resource.kops_validate.id
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "=================================================="
      echo " Step 4: kubeconfig Export చేస్తున్నాం..."
      echo "=================================================="

      kops export kubecfg \
        --name=${var.cluster_name} \
        --state=s3://${var.state_bucket_name} \
        --admin

      echo ""
      echo "=================================================="
      echo "  Cluster Ready! kubectl వాడవచ్చు!"
      echo "=================================================="
      echo ""

      kubectl get nodes
    EOT

    environment = {
      AWS_DEFAULT_REGION = var.region
      KOPS_STATE_STORE   = "s3://${var.state_bucket_name}"
    }
  }
}
