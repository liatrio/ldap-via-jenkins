terraform {
  backend "s3" {
    bucket = "ldop-demo-tfstates"
    key = "ldop-demo/demo-terraform.tfstate"
    region = "us-west-2"
  }
}

provider "aws" {
  region = "us-west-2"
}

variable "instance_name" {
  description = "The name used to identify your LDOP instance on LDOP"
}

variable "ldop_username" {
  default = "liatrio"
  description = "The initial admin username for LDOP's single sign on via LDAP."
}

variable "ldop_password" {
  default = "example123"
  description = "The initial password for the admin user. Must be at least 8 characters in length and contain at least one number."
}

variable "ami_id" {
  default = "ami-6df1e514"
  description = "The AMI ID for LDOP on ec2"
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config {
    bucket = "ldop-demo-tfstates"
    key    = "ldop-demo/${terraform.workspace}/${var.instance_name}-terraform.tfstate"
    region = "us-west-2"
  }
}

resource "aws_instance" "ldop_demo_env" {
  instance_type          = "t2.large"
  key_name               = "terraform-ldop-demo"
  ami                    = "${var.ami_id}"
  security_groups = ["web", "https server"]

  tags = {
    Name = "${var.instance_name}"
  }

  root_block_device {
    volume_size = 24
  }

  # Install docker, docker-compose and git
  provisioner "remote-exec" {
    connection {
      user        = "ec2-user"
      private_key = "${file("~/.ssh/id_rsa")}"
    }

    inline = [
      "sudo yum update -y",
      "sudo yum install -y docker",
      "sudo service docker start",
      "sudo usermod -aG docker ec2-user",
      "sudo pip install docker-compose && sudo cp /usr/local/bin/docker-compose /usr/bin/",
      "sudo yum install -y git",
      "curl https://s3-us-west-2.amazonaws.com/liatrio-authorized-keys-groups/admins >> ~/.ssh/authorized_keys",
      "curl https://s3-us-west-2.amazonaws.com/liatrio-authorized-keys-groups/chico_vets >> ~/.ssh/authorized_keys",
      "curl https://s3-us-west-2.amazonaws.com/liatrio-authorized-keys-groups/chico_wave_3 >> ~/.ssh/authorized_keys",
    ]
  }

  # Clone ldop-docker-compose repo
  provisioner "remote-exec" {
    connection {
      user        = "ec2-user"
      private_key = "${file("~/.ssh/id_rsa")}"
    }

    inline = [
      "git clone https://github.com/liatrio/ldop-docker-compose.git",
      "git -C ./ldop-docker-compose checkout master",
    ]
  }


   # start ldop
   provisioner "remote-exec" {
    connection {
      user        = "ec2-user"
      private_key = "${file("~/.ssh/id_rsa")}"
    }

    inline = [
      "cd ~/ldop-docker-compose",
      "sudo ./ldop compose -u ${var.ldop_username} -p ${var.ldop_password} init",
    ]
  }
}

data "aws_route53_zone" "liatrio" {
  name = "liatr.io"
}

resource "aws_route53_record" "url" {
  zone_id = "${data.aws_route53_zone.liatrio.zone_id}"
  name    = "${var.instance_name}.liatr.io"
  type    = "A"
  ttl     = 300
  records = ["${aws_instance.ldop_demo_env.public_ip}"]
}

