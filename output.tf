# print the url of the jenkins server
output "ssh_connection_command" {
  value     =  ["ssh -i ${var.aws_key}.pem ubuntu@${aws_instance.ec2_instance.public_dns}"]
}