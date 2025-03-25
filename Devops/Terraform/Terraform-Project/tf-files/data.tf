data "aws_vpc" "default" {
    default = true
}

data "aws_ami" "ubuntu_24" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical (Ubuntu) resmi AWS hesabı
}


data "aws_subnets" "defaultsubnets" {
  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

data "aws_route53_zone" "selected" {
  name         = var.hosted-zone
}

data "template_file" "rentaldb" {
  template = file("${abspath(path.module)}/userdata.sh")
  vars = {
    USER = var.git-user
    REPO = var.repo-name
    APP_NAME = var.app-name
    GIT_TOKEN   = data.aws_ssm_parameter.rental.value
    DOMAIN_NAME = var.domain-name
  }
}

data "aws_ssm_parameter" "rental" {
  name = "git-token"
}