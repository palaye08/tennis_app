output "ec2_public_ip" {
  description = "IP publique de l'instance EC2"
  value       = aws_instance.tennis_backend.public_ip
}

output "ec2_public_dns" {
  description = "DNS public de l'instance EC2 (généré par AWS)"
  value       = aws_instance.tennis_backend.public_dns
}

output "swagger_url" {
  description = "URL du Swagger UI — accessible ~2 min après terraform apply"
  value       = "http://${aws_instance.tennis_backend.public_ip}:${var.app_port}/swagger-ui/index.html#/"
}

output "ssh_command" {
  description = "Commande SSH pour se connecter à l'instance EC2"
  value       = "ssh -i ~/.ssh/id_rsa ec2-user@${aws_instance.tennis_backend.public_ip}"
}

output "instance_id" {
  description = "Identifiant de l'instance EC2 dans AWS"
  value       = aws_instance.tennis_backend.id
}
