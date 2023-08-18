
variable "iam_role_ecs" {
  type = string
}

variable "project_name" {
  type = string
}

variable "cluster-ecs-name" {
  type = string
}

variable "environment" {
  type = string
}

variable "task_name" {
  type = string
}

variable "region" {
  type = string
}

variable "ecs_service_name" {
  type = string
}

variable "sg" {
  type = list(string)
}
variable "sub-public" {
  type = list(string)
}

variable "target_group_arn_pub"{
  type = string
}
variable "target_group_arn_priv"{
  type = string
}

