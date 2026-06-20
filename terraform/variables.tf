# ─────────────────────────────────────────────────────────────
# La région AWS est déclarée directement dans provider.tf
# (us-west-1 = US West, N. California)
# ─────────────────────────────────────────────────────────────

variable "instance_type" {
  description = "Type d'instance EC2 (t2.micro = Free Tier éligible en us-west-1)"
  type        = string
  default     = "t2.micro"
}

variable "docker_image" {
  description = "Image Docker Hub du backend tennis"
  type        = string
  default     = "palaye769/tennis-backend:latest"
}

variable "app_port" {
  description = "Port exposé par l'application Spring Boot"
  type        = number
  default     = 8081
}

variable "ssh_allowed_ip" {
  description = "Votre IP publique pour l'accès SSH (format CIDR, ex: 41.82.100.45/32)"
  type        = string
}

variable "key_pair_name" {
  description = "Nom de la paire de clés SSH dans AWS"
  type        = string
  default     = "palaye-tennis-key"
}

variable "public_key_path" {
  description = "Chemin local vers votre clé SSH publique (~/.ssh/id_rsa.pub)"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "mysql_root_password" {
  description = "Mot de passe root MySQL (sensible — ne jamais mettre dans git)"
  type        = string
  sensitive   = true
}

variable "mysql_database" {
  description = "Nom de la base de données MySQL"
  type        = string
  default     = "tennis_db"
}
