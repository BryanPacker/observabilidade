output "ip_publico_interno" {
  description = "O IP publico da instancia criado dentro do modulo"
  value       = aws_instance.instance_Bryan.public_ip
}
output "ssh_connection_string" {
  description = "Command to SSH into the instance"
  value       = "ssh -i bryan_key.pem ubuntu@${aws_instance.instance_Bryan.public_ip}"
}
output "https_connection_string" {
  description = "Command to access HTTPS into the instance"
  value       = "https://${aws_instance.instance_Bryan.public_ip}"
}
