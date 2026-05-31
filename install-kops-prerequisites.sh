#!/bin/bash
set -e

echo "=================================================="
echo "  Kops + Terraform Prerequisites Installer"
echo "  Ubuntu 24.04 LTS (EC2)"
echo "=================================================="

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

ok()   { echo -e "${GREEN}[OK]${NC} $1"; }
info() { echo -e "${YELLOW}[..] $1${NC}"; }
fail() { echo -e "${RED}[FAIL]${NC} $1"; exit 1; }

# ── 1. System update ──────────────────────────────────
info "System packages update chesthunam..."
sudo apt-get update -y -qq
sudo apt-get install -y curl unzip wget git jq
ok "System packages ready"

# ── 2. AWS CLI v2 ─────────────────────────────────────
info "AWS CLI v2 install chesthunam..."
cd /tmp
curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
unzip -q awscliv2.zip
sudo ./aws/install --update
rm -rf awscliv2.zip aws/
ok "AWS CLI installed: $(aws --version 2>&1)"

# ── 3. Terraform ──────────────────────────────────────
info "Terraform 1.6.6 install chesthunam......"
cd /tmp
TF_VERSION="1.6.6"
wget -q "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip" -O tf.zip
unzip -q tf.zip
sudo mv terraform /usr/local/bin/terraform
sudo chmod +x /usr/local/bin/terraform
rm -f tf.zip
ok "Terraform installed: $(terraform --version | head -1)"

# ── 4. Kops ───────────────────────────────────────────
info "Kops 1.28.0 install chesthunam..."
cd /tmp
KOPS_VERSION="1.28.0"
curl -fsSLo kops "https://github.com/kubernetes/kops/releases/download/v${KOPS_VERSION}/kops-linux-amd64"
chmod +x kops
sudo mv kops /usr/local/bin/kops
ok "Kops installed: $(kops version)"

# ── 5. kubectl ────────────────────────────────────────
info "kubectl 1.28.0 install chesthunam..."
cd /tmp
K8S_VERSION="v1.28.0"
curl -fsSLo kubectl "https://dl.k8s.io/release/${K8S_VERSION}/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/kubectl
ok "kubectl installed: $(kubectl version --client --short 2>/dev/null || kubectl version --client)"

# ── 6. SSH Key (kops ki kavaliii) ───────────────────────
info "SSH keypair check chesthunam..."
if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N "" -q
    ok "SSH keypair created at ~/.ssh/id_rsa"
else
    ok "SSH keypair already exists at ~/.ssh/id_rsa"
fi

# ── 7. Environment variables (~/.bashrc lo add avuthaiii) ──
info "Environment variables set chesthunam..."
BASHRC="$HOME/.bashrc"

grep -q "KOPS_STATE_STORE" "$BASHRC" 2>/dev/null || cat >> "$BASHRC" << 'ENVEOF'

# ── Kops Environment Variables ──
export KOPS_STATE_STORE="s3://my-kops-state-store-bucket"   # mi bucket name paiitandii
export KOPS_CLUSTER_NAME="mycluster.k8s.local"
export AWS_DEFAULT_REGION="ap-south-1"
ENVEOF
ok "Environment variables added to ~/.bashrc"

# ── 8. Final Summary ──────────────────────────────────
echo ""
echo "=================================================="
echo -e "${GREEN}  All Prerequisites Installed Successfully!${NC}"
echo "=================================================="
echo ""
echo "Installed versions:"
echo "  AWS CLI   : $(aws --version 2>&1 | cut -d' ' -f1)"
echo "  Terraform : $(terraform --version | head -1)"
echo "  Kops      : $(kops version)"
echo "  kubectl   : $(kubectl version --client --short 2>/dev/null | head -1 || echo 'v1.28.0')"
echo ""
echo "=================================================="
echo "  NEXT STEPS:"
echo "=================================================="
echo ""
echo "  Step 1: AWS Credentials configure cheyyandii:"
echo "    aws configure"
echo ""
echo "  Step 2: ~/.bashrc lo bucket name Marchandii:"
echo "    nano ~/.bashrc"
echo "    (KOPS_STATE_STORE lo mi bucket name Paitandii)"
echo ""
echo "  Step 3: Changes load cheyyandii:"
echo "    source ~/.bashrc"
echo ""
echo "  Step 4: AWS connection test cheyyandii:"
echo "    aws sts get-caller-identity"
echo "=================================================="
