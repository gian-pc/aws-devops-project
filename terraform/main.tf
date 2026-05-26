# ============================================================
# CONFIGURACIÓN PRINCIPAL DE TERRAFORM
# ============================================================
# Este archivo es el punto de entrada del proyecto.
# Define la versión de Terraform y el proveedor de AWS.

terraform {
  # Versión mínima de Terraform requerida para este proyecto
  required_version = ">= 1.0"

  required_providers {
    # Proveedor oficial de AWS — es el plugin que permite
    # a Terraform crear y gestionar recursos en AWS
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Usa versión 5.x, evita cambios de versión mayor
    }
  }
}

provider "aws" {
  # La región donde se crearán todos los recursos AWS.
  # Usamos una variable en vez de hardcodear "us-east-1"
  # para que sea fácil cambiar de región si se necesita.
  region = var.aws_region
}