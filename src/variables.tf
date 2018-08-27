variable "access_key" {}
variable "secret_key" {}

variable "key_name" {}

variable "name" {
  default = "test"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "region" {
  default = "us-east-1"
}

variable "vpn_instance_type" {
  default = "t2.small"
}
