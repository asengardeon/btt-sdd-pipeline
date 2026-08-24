variable "environment" {
  description = "Nome do ambiente (ex.: staging, production)."
  type        = string
}

variable "aws_region" {
  description = "Região AWS onde os recursos serão criados."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome do projeto, usado para nomear/tagueiar recursos de forma consistente."
  type        = string
  default     = "projeto-base-ia"
}

variable "container_image" {
  description = "URI completa da imagem de container a implantar (ex.: saída do job de CD)."
  type        = string
}

variable "container_cpu" {
  description = "CPU units (Fargate) alocados ao container."
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "Memória (MiB, Fargate) alocada ao container."
  type        = number
  default     = 512
}

variable "app_secrets" {
  description = "Segredos de aplicação injetados como variáveis de ambiente do container."
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "tags" {
  description = "Tags padrão aplicadas a todos os recursos."
  type        = map(string)
  default     = {}
}
