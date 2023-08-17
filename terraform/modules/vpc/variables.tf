
variable "vpc_name" {
  type = string
}
variable "cidr_vpc" {
  type = string
}

variable "pub_sub" {
  type = list(string)
}

variable "private_sub" {
  type = list(string)
}

variable "region" {
  type = string
}

