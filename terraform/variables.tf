# ============================================================
# VARIABLES DEL PROYECTO
# ============================================================
# Centraliza todos los valores configurables del proyecto.
# Así no hay valores hardcodeados en el código.

variable "aws_region" {
  description = "Región de AWS donde se desplegará la infraestructura"
  type        = string
  default     = "us-east-1" # N. Virginia — región principal
}

variable "project_name" {
  description = "Nombre del proyecto — se usa para nombrar todos los recursos"
  type        = string
  default     = "aws-devops-project"
}

variable "environment" {
  description = "Ambiente de despliegue: dev, staging o prod"
  type        = string
  default     = "dev"
}