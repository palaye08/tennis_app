# ─────────────────────────────────────────────────────────────
# AMI Amazon Linux 2023 — la plus récente dans us-west-1
# AWS met à jour cette AMI régulièrement ; ce data source
# détecte automatiquement la dernière version disponible.
# ─────────────────────────────────────────────────────────────
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ─────────────────────────────────────────────────────────────
# Paire de clés SSH
# Terraform lit votre clé publique locale (~/.ssh/id_rsa.pub)
# et l'importe dans AWS. Votre clé privée (~/.ssh/id_rsa)
# reste uniquement sur votre machine — AWS ne la voit jamais.
# ─────────────────────────────────────────────────────────────
resource "aws_key_pair" "tennis_key" {
  key_name   = var.key_pair_name
  public_key = file(var.public_key_path)

  tags = {
    Name    = var.key_pair_name
    Project = "tennis-backend"
  }
}

# ─────────────────────────────────────────────────────────────
# Security Group (pare-feu de l'instance EC2)
# Règles entrantes (ingress) :
#   - Port 22  : SSH, uniquement depuis votre IP
#   - Port 8081: Application publique (tout le monde)
# Règles sortantes (egress) :
#   - Tout autorisé (pour docker pull, dnf update, etc.)
# ─────────────────────────────────────────────────────────────
resource "aws_security_group" "tennis_sg" {
  name        = "tennis-backend-sg"
  description = "Tennis backend : SSH restreint + port app public"

  ingress {
    description = "SSH depuis mon IP uniquement"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_ip]
  }

  ingress {
    description = "Tennis backend API - acces public"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Tout le trafic sortant autorise"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "tennis-backend-sg"
    Project = "tennis-backend"
  }
}

# ─────────────────────────────────────────────────────────────
# Instance EC2
# - AMI      : Amazon Linux 2023 (détectée automatiquement)
# - Type     : t2.micro (Free Tier en us-west-1)
# - user_data: script exécuté au 1er démarrage de l'instance
#              → installe Docker + Docker Compose
#              → génère le docker-compose.yml (MySQL + backend)
#              → lance les conteneurs
#              → crée un service systemd pour redémarrer au reboot
# ─────────────────────────────────────────────────────────────
resource "aws_instance" "tennis_backend" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.tennis_key.key_name
  vpc_security_group_ids      = [aws_security_group.tennis_sg.id]
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    docker_image        = var.docker_image
    app_port            = tostring(var.app_port)
    mysql_root_password = var.mysql_root_password
    mysql_database      = var.mysql_database
  })

  user_data_replace_on_change = true

  tags = {
    Name    = "tennis-backend-ec2"
    Project = "tennis-backend"
    Region  = "us-west-1"
  }
}
