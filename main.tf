provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

module "vpn" {
  source = "https://github.com/ehime/terraform-securelab//module"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "test" {
  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "m3.medium"
  subnet_id              = "${module.vpc_lab.subnet_id}"
  vpc_security_group_ids = ["${module.vpc_lab.security_group_id}"]
}

resource "aws_route53_record" "test" {
  zone_id = "${module.vpc_lab.zone_id}"
  name    = "test.${module.vpc_lab.domain}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.test.private_ip}"]
}

output "vpn_ip" {
  value = "${module.vpc_lab.vpn_ip}"
}

output "vpn_sharedkey" {
  value = "${module.vpc_lab.vpn_sharedkey}"
}

output "vpn_user" {
  value = "${module.vpc_lab.vpn_user}"
}

output "vpn_password" {
  value = "${module.vpc_lab.vpn_password}"
}
