output "cluster_name" {
  description = "Nome do cluster ECS criado."
  value       = aws_ecs_cluster.this.name
}

output "service_name" {
  description = "Nome do serviço ECS criado."
  value       = aws_ecs_service.this.name
}
