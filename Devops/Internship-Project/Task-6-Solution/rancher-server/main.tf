terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.73.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_instance" "rancher-server" {
  ami= var.myami
  instance_type = var.ec2_type
  root_block_device {
    volume_size = 20            # Root volume boyutu 20 GB olarak ayarlanıyor
    volume_type = "gp2"         # General Purpose SSD
    delete_on_termination = true  # Instance silindiğinde volume da silinsin
  }
  key_name = var.ec2_key
  vpc_security_group_ids = [aws_security_group.rancher-server-sgr.id]
  tags = {
    Name = "Rancher-Server"
  }
}

resource "aws_security_group" "rancher-server-sgr" {
  name        = "Rancher-Server-Sgr"
  description = "Rancher Server Security Group"

  dynamic "ingress" {
    for_each = var.ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"] 
    }
  }
  egress {
    from_port   = 0
    protocol    = -1
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}