
provider "aws" {
  region = "us-east-1"  
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "my-ecs-cluster"
}

data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                   = "my-ecs-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    name      = "my-node-app"
    image     = var.docker_image
    cpu       = 256
    memory    = 512
    essential = true
    portMappings = [{
      containerPort = 3000
      hostPort      = 3000
    }]
  }])
}


resource "aws_ecs_service" "ecs_service" {
  name            = "my-ecs-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = ["subnet-05d87a98545cd0c56"]  
    security_groups = ["sg-0561a79cc8203131b"]      
    assign_public_ip = true
  }
}


variable "docker_image" {
  description = "Docker image name"
  type        = string
}
