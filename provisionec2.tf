provider "aws" {
  region = "us-west-2" 

}
resource "aws_instance" "prometheus_grafana" {
  ami           = "ami-05134c8ef96964280" 
  instance_type = "t3.micro"

  tags = {
    Name = "PrometheusGrafanaa"
  }
key_name = "key1"

vpc_security_group_ids = [aws_security_group.prometheus_grafannn.id]
}
resource "aws_security_group" "prometheus_grafannn" {
  name        = "prometheus_grafannn"

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