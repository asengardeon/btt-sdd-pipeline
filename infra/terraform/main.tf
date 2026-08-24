provider "aws" {
  region = var.aws_region

  default_tags {
    tags = merge(var.tags, {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    })
  }
}

locals {
  name = "${var.project_name}-${var.environment}"
}

resource "aws_ecr_repository" "app" {
  name                 = local.name
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

module "ecs_service" {
  source = "./modules/ecs-service"

  name             = local.name
  container_image  = var.container_image
  container_cpu    = var.container_cpu
  container_memory = var.container_memory
  app_secrets      = var.app_secrets
  tags             = var.tags
}
