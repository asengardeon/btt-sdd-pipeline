output "ecr_repository_url" {
  description = "URL do repositório ECR onde a imagem da aplicação deve ser publicada."
  value       = aws_ecr_repository.app.repository_url
}

output "ecs_service_name" {
  description = "Nome do serviço ECS criado pelo módulo ecs-service."
  value       = module.ecs_service.service_name
}
