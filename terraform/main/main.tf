module "vpc" {
  source   = "../modules/vpc"
  vpc_name = "VPC-ECS-CONNECT-1"
  cidr_vpc = "10.100.0.0/16"
  pub_sub  = ["10.100.1.0/24", "10.100.2.0/24", "10.100.3.0/24"]
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