variable "myami" {
  type = map(string)
  default = {
    dev = "ami-0953476d60561c955" # Amazon Linux 2023
    prod  = "ami-03a13a09a711d3871" # Red Hat Enterprise Linux 10
    test   = "ami-084568db4383264d4" # Ubuntu Server 24.04 LTS
  }
  description = "in order of Amazon Linux 2023 ami, Red Hat Enterprise Linux 10 ami and Ubuntu Server 24.04 LTS"
}

variable "ec2_type" {
  default = "t2.micro"
}


variable "num_of_instance" {
    default = 1
  }

variable "ec2_key" {
    default = "techpro-key"
  }

variable "ports" {
  type = map(list(number))
  default = {
    default = [80, 443, 22]
    dev= [80, 443, 22, 5432, 3000, 5000, 3306, 8090]
    test= [80, 443, 22, 8080, 8090, 3000, 5432]
    prod= [22, 80, 443, 8080, 9000, 8090, 3000, 5432]
  }
}