provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "ami_id" {
  type        = string
  description = "Golden AMI ID created by Packer. Run packer build packer.json first."
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

resource "aws_instance" "golden_ami_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name = "golden-ami-ec2"
  }
}

output "instance_id" {
  value = aws_instance.golden_ami_instance.id
}

output "public_ip" {
  value = aws_instance.golden_ami_instance.public_ip
}
