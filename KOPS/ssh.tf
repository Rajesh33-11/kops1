# ─────────────────────────────────────────────────────
# SSH Key — Terraform Automatic గా Generate చేస్తుంది
# మీరు manually ssh-keygen run చేయక్కర్లేదు!
# ─────────────────────────────────────────────────────

# Step 1: RSA Private Key Terraform తోనే Generate చేయడం
resource "tls_private_key" "kops_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Step 2: Private Key ని EC2 లో File గా Save చేయడం
resource "local_file" "private_key" {
  content         = tls_private_key.kops_ssh.private_key_pem
  filename        = "${path.module}/kops-ssh-key.pem"
  file_permission = "0600"   # Owner మాత్రమే read చేయగలడు (security!)
}

# Step 3: Public Key ని EC2 లో File గా Save చేయడం
resource "local_file" "public_key" {
  content         = tls_private_key.kops_ssh.public_key_openssh
  filename        = "${path.module}/kops-ssh-key.pub"
  file_permission = "0644"
}

# Step 4: AWS లో Key Pair Register చేయడం
resource "aws_key_pair" "kops" {
  key_name   = "${replace(var.cluster_name, ".", "-")}-keypair"
  public_key = tls_private_key.kops_ssh.public_key_openssh

  tags = {
    Name    = "Kops SSH Keypair"
    Cluster = var.cluster_name
  }
}
