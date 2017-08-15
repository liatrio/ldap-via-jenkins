data "terraform_remote_state" "network" {
  backend = "s3"
  config {
    bucket = "ldop-demo-tfstates"
    key    = "ldop-demo/demo-terraform.tfstate"
    region = "us-west-2"
  }
}

provider "aws" {
  region = "us-west-2"
}

variable "ami_id" {
  default = "ami-6df1e514"
  description = "The AMI ID for LDOP on ec2"
}

resource "aws_security_group" "demo_env" {
  name = "ldop_demo_env"

  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_key_pair" "demo_key" {
  key_name = "terraform-ldop-demo"
  public_key = "${file("${path.module}/terraform.key.pub")}"
}

resource "aws_instance" "ldop_demo_env" {
  instance_type          = "t2.large"
  key_name               = "${aws_key_pair.demo_key.key_name}"
  ami                    = "${var.ami_id}"
  vpc_security_group_ids = ["${aws_security_group.demo_env.id}"]

  tags = {
    Name = "terraform_ldop_demo"
  }

  root_block_device {
    volume_size = 24
  }

  # Install docker, docker-compose and git
  provisioner "remote-exec" {
    connection {
      user        = "ec2-user"
      private_key = "${file("${path.module}/terraform.key")}"
    }

    inline = [
      "sudo yum update -y",
      "sudo yum install -y docker",
      "sudo service docker start",
      "sudo usermod -aG docker ec2-user",
      "sudo pip install docker-compose && sudo cp /usr/local/bin/docker-compose /usr/bin/",
      "sudo yum install -y git",
    ]
  }

  # Clone ldop-docker-compose repo
  provisioner "remote-exec" {
    connection {
      user        = "ec2-user"
      private_key = "${file("${path.module}/terraform.key")}"
    }

    inline = [
      "git clone https://github.com/liatrio/ldop-docker-compose.git",
      "git -C ./ldop-docker-compose checkout master",
    ]
  }

  # Copy new docker-compose file
  provisioner "file" {
    connection {
      user        = "ec2-user"
      private_key = "${file("${path.module}/terraform.key")}"
    }

    source      = "${path.module}/../../docker-compose.yml"
    destination = "~/ldop-docker-compose/docker-compose.yml"
  }

   # start ldop
   provisioner "remote-exec" {
    connection {
      user        = "ec2-user"
      private_key = "${file("${path.module}/terraform.key")}"
    }

    inline = [
      "cd ~/ldop-docker-compose",
      "sudo ./ldop compose init",
    ]
  }
}
