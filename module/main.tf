/** Buh bye
provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
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
  ami                         = "${data.aws_ami.ubuntu.id}"
  instance_type               = "${var.vpn_instance_type}"
  subnet_id                   = "${aws_subnet.public.id}"
  vpc_security_group_ids      = ["${aws_security_group.vpn.id}"]
  associate_public_ip_address = true
  key_name                    = "${var.key_name}"

  tags {
    Name        = "test0-${var.name}"
    Environment = "${var.name}"
  }
}

resource "aws_route53_record" "test0" {
  zone_id = "${aws_route53_zone.main.zone_id}"
  name    = "test0.${var.name}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.test.private_ip}"]
}
*/

