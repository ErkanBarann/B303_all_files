locals {
  tag="rental"
}

resource "aws_security_group" "alb-sg" {
  name = "ALBSecurityGroup"
  vpc_id = data.aws_vpc.default.id
  tags = {
    Name = "${local.tag}-ALBSecurityGroup"
  }
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ec2-sg" {
  name = "WebServerSecurityGroup"
  vpc_id = data.aws_vpc.default.id
  tags = {
    Name = "${local.tag}-WebServerSecurityGroup"
  }

  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    security_groups = [aws_security_group.alb-sg.id]
  }

  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

}


resource "aws_security_group" "db-sg" {
  name = "RDSSecurityGroup"
  vpc_id = data.aws_vpc.default.id
  tags = {
    "Name" = "${local.tag}-RDSSecurityGroup"
  }
  ingress {
    security_groups = [aws_security_group.ec2-sg.id]
    from_port = 3306
    protocol = "tcp"
    to_port = 3306
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    protocol = -1
    to_port = 0
  }
}

resource "aws_launch_template" "rental-lt" {
  name = "rental-lt"
  image_id = data.aws_ami.ubuntu_24.id
  instance_type = "t2.micro"
  key_name = var.key-name
  vpc_security_group_ids = [aws_security_group.ec2-sg.id]
  user_data = base64encode(data.template_file.rentaldb.rendered)
  depends_on = [github_repository_file.env_file]
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${local.tag}-LaunchTemplate"
    }
  }
}

resource "github_repository_file" "env_file" {
  repository = var.repo-name
  file       = "dbendpoint"        
  content    = "DB_HOST=${aws_db_instance.db-server.address}"
  commit_message = "Update .env file"
  branch         = "main"  
}


resource "aws_db_subnet_group" "default" {
  name       = "rental"
  subnet_ids = data.aws_subnets.defaultsubnets.ids

  tags = {
    Name = "${local.tag}-subnet group"
  }
}

resource "aws_db_instance" "db-server" {
  instance_class = "db.t3.micro"
  allocated_storage = 20
  vpc_security_group_ids = [aws_security_group.db-sg.id]
  allow_major_version_upgrade = false
  auto_minor_version_upgrade = true
  backup_retention_period = 0
  db_subnet_group_name = aws_db_subnet_group.default.name
  identifier = "rental-app-db"
  db_name = var.dbname
  engine = "mysql"
  engine_version = "8.0.40"
  username = var.dbuser
  password = var.dbsifre
  monitoring_interval = 0
  multi_az = false
  port = 3306
  publicly_accessible = false
  skip_final_snapshot = true
}

resource "aws_autoscaling_group" "app-asg" {
  max_size = 3
  min_size = 1
  desired_capacity = 2
  name = "rental-asg"
  health_check_grace_period = 60
  health_check_type = "ELB"
  target_group_arns = [aws_alb_target_group.app-lb-tg.arn]
  vpc_zone_identifier = aws_alb.app-lb.subnets
  launch_template {
    id = aws_launch_template.rental-lt.id
    version = aws_launch_template.rental-lt.latest_version
  }
}


resource "aws_alb" "app-lb" {
  name = "rental-lb-tf"
  ip_address_type = "ipv4"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.alb-sg.id]
  subnets = data.aws_subnets.defaultsubnets.ids
}

resource "aws_alb_listener" "app-listener" {
  load_balancer_arn = aws_alb.app-lb.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_alb_target_group.app-lb-tg.arn
  }
}

resource "aws_alb_target_group" "app-lb-tg" {
  name = "rental-lb-tg"
  port = 80
  protocol = "HTTP"
  vpc_id = data.aws_vpc.default.id
  target_type = "instance"

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 3
  }
}


resource "aws_route53_record" "rental" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "www.${var.hosted-zone}"
  type    = "A"

  alias {
    name                   = aws_alb.app-lb.dns_name
    zone_id                = aws_alb.app-lb.zone_id
    evaluate_target_health = true
  }
}


# resource "aws_s3_bucket" "tf-remote-state" {
#   bucket = "contactlist-backend-techpro"

#   force_destroy = true   
# }

# resource "aws_s3_bucket_server_side_encryption_configuration" "mybackend" {
#   bucket = aws_s3_bucket.tf-remote-state.bucket

#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"    
#     }
#   }
# }

# resource "aws_s3_bucket_versioning" "versioning_backend_s3" {
#   bucket = aws_s3_bucket.tf-remote-state.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# resource "aws_dynamodb_table" "tf-remote-state-lock" {
#   hash_key = "LockID"
#   name     = "tf-s3-app-lock"
#   attribute {
#     name = "LockID"
#     type = "S"
#   }
#   billing_mode = "PAY_PER_REQUEST"
# }





