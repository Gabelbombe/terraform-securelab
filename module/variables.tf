/** Buh bye
variable "access_key" {}
variable "secret_key" {}
*/

variable "key_name" {
  description = "Amazon EC2 key pair name to create VPN instance with"
  default     = ""
}

variable "name" {
  default = "test"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "vpn_instance_type" {
  default = "t2.small"
}

variable "vpn_subnet" {
  description = "Subnet to build for the VPN. Define if you need custom network layout"
  default     = ""
}

variable "vpn_user" {
  description = "VPN User"
  default     = ""
}

variable "vpn_psk" {
  description = "Pre-Shared Key for VPN"
  default     = ""
}

variable "vpn_password" {
  description = "Password for VPN user"
  default     = ""
}
