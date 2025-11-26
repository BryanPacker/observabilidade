data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}
resource "aws_subnet" "bryan_subnet" {
  vpc_id            = var.vpc_id
  cidr_block        = var.cidr_block
  availability_zone = var.availability_zone
  tags = {
    Name = var.subnet_name
  }
}
resource "aws_security_group" "bryan_sg" {
  name_prefix = "bryan-sg-"
  vpc_id      = var.vpc_id
  # Regra de entrada - HTTP
  # Regra de entrada - SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Regra de saída - Permite tudo
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = var.sg_name
  }
}
resource "tls_private_key" "bryan_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "bryan_key" {
  key_name   = "bryan-key"
  public_key = tls_private_key.bryan_key.public_key_openssh
}

resource "local_file" "private_key" {
  filename        = "${path.module}/bryan_key.pem"
  content         = tls_private_key.bryan_key.private_key_pem
  file_permission = "0600"
}
resource "aws_instance" "instance_Bryan" {

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.bryan_sg.id]
  subnet_id                   = aws_subnet.bryan_subnet.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.bryan_key.key_name
  user_data = <<-EOF
    #!/bin/bash
    sleep 20
    apt-get update
    apt-get install -y docker.io git apache2-utils openssl
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ubuntu
    curl -SL https://github.com/docker/compose/releases/download/v2.29.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
    PROJECT_DIR="/home/ubuntu/Aula-Observabilidade"
    sudo -u ubuntu git clone https://github.com/BryanPacker/observabilidade.git $PROJECT_DIR
    sudo -u ubuntu bash -c "cd $PROJECT_DIR && chmod +x nginxpasswrd.sh && ./nginxpasswrd.sh"
    chown -R ubuntu:ubuntu $PROJECT_DIR
    sudo -u ubuntu bash -c "cd /home/ubuntu/Aula-Observabilidade && docker-compose -f docker-compose.yml -f docker-compose-override.yml up -d"
    EOF                             
              
  tags = {
    Name = var.instance_name
  }
}
