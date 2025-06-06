variable "myami" {
  default ="ami-0866a3c8686eaeeba"
  description = "Ubuntu Server 24.04 LTS"
}


variable "ports" {
  type    = list(number)
  default = [80, 443, 6443, 8080, 10250, 22, 8472, 9200, 9300, 5601, 24231]
}


variable "region" {
  default = "us-east-1"  
}


variable "ec2_type" {
  default = "t3a.medium"
}

variable "ec2_key" {
  default = "insbekir" # change here
}
