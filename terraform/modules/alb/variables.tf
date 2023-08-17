variable "sg-id" {
    type = list(string)
}

variable "pub-sub" {
    type = list(string)
}

variable "private-sub" {
    type = list(string)
}

variable "pub-alb-name" {
    type = string
}

variable "private-alb-name"{
    type = string
}

variable "name_target_group"{
  type = string
}

variable "certificate_arn"{
    type = string
}

variable "vpc_id"{
    type = string
}