locals {
  load_balancer = {
    public = module.elb.target_group_id_pub
    private = module.elb.target_group_id_private
  }
}

module "vpc" {
  source   = "../modules/vpc"
  vpc_name = "VPC-ECS-CONNECT-1"
  cidr_vpc = "10.100.0.0/16"
  pub_sub  = ["10.100.1.0/24", "10.100.2.0/24", "10.100.3.0/24"]
  private_sub = ["10.100.4.0/24", "10.100.5.0/24", "10.100.6.0/24"]
  region   = var.region
}


module "elb"{
  source = "../modules/alb"
  vpc_id = module.vpc.vpc_id
  pub-alb-name = "ALB-PUB-ECS-CONNECT-1"
  private-alb-name = "ALB-PRIVATE-ECS-CONNECT-1"
  sg-id = [module.vpc.sg-service]
  pub-sub = module.vpc.sub-public
  private-sub = module.vpc.sub-private
  certificate_arn = "arn:aws:acm:us-west-2:431591413306:certificate/82cc4873-52b4-4987-8409-6d322bf2da34"
  name_target_group_pub = "TG-PUBLIC-ECS-CONNECT-1"
  name_target_group_private = "TG-PRIVATE-ECS-CONNECT-1"

}


module "vpc-connect-2" {
  source   = "../modules/vpc"
  vpc_name = "VPC-ECS-CONNECT-2"
  cidr_vpc = "10.110.0.0/16"
  pub_sub  = ["10.110.1.0/24", "10.110.2.0/24", "10.110.3.0/24"]
  private_sub = ["10.110.4.0/24", "10.110.5.0/24", "10.110.6.0/24"]
  region   = var.region
}

module "ecs-1" {
  source           = "../modules/ecs"
  iam_role_ecs     = "ECS-TASK-EXECUTION-ROLE-ECS-SERVICE-CONNECT-1"
  cluster-ecs-name = "ECS-SERVICE-CONNECT-1"
  project_name     = "application-form"
  ecs_service_name = "application-form"
  environment      = "dev"
  task_name        = "application-form"
  region           = var.region
  sg               = [module.vpc.sg-service]
  sub-public       = module.vpc.sub-public
  load_balancer = {
    
  }
}

module "ecs-2" {
  source           = "../modules/ecs"
  iam_role_ecs     = "ECS-TASK-EXECUTION-ROLE-ECS-SERVICE-CONNECT-2"
  cluster-ecs-name = "ECS-SERVICE-CONNECT-2"
  project_name     = "storage-files"
  ecs_service_name = "storage-files"
  environment      = "dev"
  task_name        = "storage-files"
  region           = var.region
  sg               = [module.vpc.sg-service]
  sub-public       = module.vpc.sub-public
}