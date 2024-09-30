provider "aws" {
  region = "us-west-2" 

}
resource "aws_instance" "prometheus_grafana" {
  ami           = "ami-05134c8ef96964280" 
  instance_type = "t3.micro"

  tags = {
    Name = "PrometheusGrafana"
  }
key_name = "key1"

vpc_security_group_ids = [aws_security_group.prometheus_grafana.id]
}
resource "aws_security_group" "prometheus_grafana" {
  name        = "prometheus_grafana"

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "null_resource" "update_ansible_hosts" {
  provisioner "local-exec" {
    command = <<EOT
      echo "[ec2]" > ./hosts
      echo "${aws_instance.prometheus_grafana.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/${aws_instance.prometheus_grafana.key_name}.pem" >> ./hosts
    EOT
  }

  depends_on = [aws_instance.prometheus_grafana]
}