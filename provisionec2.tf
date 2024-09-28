provider "aws" {
  region = "us-west-2" 

}
resource "aws_instance" "prometheus_grafana" {
  ami           = "ami-0e42b3cc568cd07e3" 
  instance_type = "t2.micro"

  tags = {
    Name = "PrometheusGrafana"
  }
key_name = "key1"
user_data = <<-EOF
              #!/bin/bash
              # Update packages
              sudo apt-get update -y
              
              # Install Prometheus
              sudo useradd --no-create-home --shell /bin/false prometheus
              sudo mkdir /etc/prometheus
              sudo mkdir /var/lib/prometheus

              # Download Prometheus
              wget https://github.com/prometheus/prometheus/releases/download/v2.44.0/prometheus-2.44.0.linux-amd64.tar.gz
              tar -xvf prometheus-2.44.0.linux-amd64.tar.gz
              cd prometheus-2.44.0.linux-amd64
              sudo mv prometheus /usr/local/bin/
              sudo mv promtool /usr/local/bin/
              sudo mv consoles /etc/prometheus
              sudo mv console_libraries /etc/prometheus
              sudo mv prometheus.yml /etc/prometheus

              # Set permissions for Prometheus directories
              sudo chown -R prometheus:prometheus /etc/prometheus
              sudo chown -R prometheus:prometheus /var/lib/prometheus
              
              # Create Prometheus service file
              sudo bash -c 'cat << EOF > /etc/systemd/system/prometheus.service
              [Unit]
              Description=Prometheus
              Wants=network-online.target
              After=network-online.target

              [Service]
              User=prometheus
              ExecStart=/usr/local/bin/prometheus --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/var/lib/prometheus

              [Install]
              WantedBy=multi-user.target
              EOF'
              
              # Install Grafana
              sudo apt-get install -y software-properties-common
              sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
              sudo apt-get install -y apt-transport-https
              sudo apt-get install -y grafana

             #------------ Start Prometheus service and Grafana service
              sudo systemctl daemon-reload
              sudo systemctl start prometheus
              sudo systemctl enable prometheus
               
              sudo systemctl start grafana-server
              sudo systemctl enable grafana-server

              EOF

  # Enable inbound traffic for Prometheus (port 9090) and Grafana (port 3000)
  vpc_security_group_ids = [aws_security_group.prometheus_grafana_sg.id]
}
resource "aws_security_group" "prometheus_grafana_sgg" {
  name        = "prometheus_grafana_sgg"

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