variable "name" {
  description = "Nome base do serviço (usado para task definition, cluster e log group)."
  type        = string
}

variable "container_image" {
  description = "URI completa da imagem de container a implantar."
  type        = string
}

variable "container_port" {
  description = "Porta exposta pelo container, se a aplicação servir tráfego."
  type        = number
  default     = 8080
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

variable "desired_count" {
  description = "Número de tasks desejadas em execução."
  type        = number
  default     = 1
}

variable "app_secrets" {
  description = "Segredos de aplicação injetados como variáveis de ambiente do container."
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "tags" {
  description = "Tags aplicadas aos recursos deste módulo."
  type        = map(string)
  default     = {}
}
