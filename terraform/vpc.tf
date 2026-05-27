# ============================================================
# RED PRINCIPAL — VPC
# ============================================================
# T0do recurso en AWS vive dentro de una VPC.
# Es tu red privada aislada del resto de AWS.
# Equivale al "edificio" donde viven todos tus recursos.

resource "aws_vpc" "main" {
  # Rango de IPs de toda la red. 10.0.0.0/16 permite
  # hasta 65,536 direcciones IP para asignar a recursos.
  cidr_block = "10.0.0.0/16"

  # Permite que los recursos tengan nombres de dominio
  # automáticos. Necesario para que EC2 y RDS se comuniquen
  # por nombre en vez de solo por IP.
  enable_dns_hostnames = true

  # Activa el servidor DNS interno de la VPC.
  # Siempre va junto con enable_dns_hostnames.
  enable_dns_support = true

  # Etiquetas para identificar el recurso en la consola AWS.
  # ${var.project_name} se reemplaza por "aws-devops-project".
  tags = {
    Name        = "${var.project_name}-vpc"
    Environment = var.environment
  }
}

# ============================================================
# INTERNET GATEWAY
# ============================================================
# Puerta de entrada/salida entre tu VPC e internet.
# Sin esto, ningún recurso puede comunicarse con el exterior.
# Solo hay uno por VPC.

resource "aws_internet_gateway" "main" {
  # Lo conectamos a nuestra VPC usando su ID.
  # aws_vpc.main.id = referencia al recurso VPC que creamos arriba.
  # Terraform sabe que debe crear la VPC primero antes del gateway.
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-igw"
    Environment = var.environment
  }
}

# ============================================================
# SUBNET PÚBLICA
# ============================================================
# Aquí vivirá el EC2 con Spring Boot.
# Es accesible desde internet a través del Internet Gateway.
# Equivale a la "recepción" del edificio.

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id

  # Subconjunto del rango de la VPC (10.0.0.0/16).
  # Esta subnet tiene IPs del rango 10.0.1.0 — 10.0.1.255
  # (256 direcciones disponibles).
  cidr_block = "10.0.1.0/24"

  # En qué zona física de AWS vive esta subnet.
  # "a" = primera zona de us-east-1 (us-east-1a).
  availability_zone = "${var.aws_region}a"

  # Los recursos en esta subnet reciben IP pública automáticamente.
  # Necesario para que el EC2 sea accesible desde internet.
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-subnet-public"
    Environment = var.environment
  }
}

# ============================================================
# SUBNET PRIVADA
# ============================================================
# Aquí vivirá RDS (PostgreSQL).
# No tiene acceso directo a internet.
# Solo el EC2 puede conectarse a ella.
# Equivale a las "oficinas internas" del edificio.

resource "aws_subnet" "private" {
  vpc_id = aws_vpc.main.id

  # Rango distinto al de la subnet pública.
  # 10.0.2.0 — 10.0.2.255
  cidr_block = "10.0.2.0/24"

  # Zona "b" — distinta a la subnet pública.
  # Buena práctica: distribuir en zonas distintas
  # para mayor disponibilidad.
  availability_zone = "${var.aws_region}b"

  tags = {
    Name        = "${var.project_name}-subnet-private"
    Environment = var.environment
  }
}

# ============================================================
# TABLA DE RUTAS PÚBLICA
# ============================================================
# Define cómo sale el tráfico de la subnet pública.
# Es como el "mapa de rutas" de tu red.

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    # 0.0.0.0/0 significa "cualquier destino" — todo el tráfico
    # que no sea interno sale por el Internet Gateway.
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "${var.project_name}-rt-public"
    Environment = var.environment
  }
}

# ============================================================
# ASOCIACIÓN TABLA DE RUTAS — SUBNET PÚBLICA
# ============================================================
# Conecta la tabla de rutas a la subnet pública.
# Sin esto, la subnet no sabe por dónde salir a internet.

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}