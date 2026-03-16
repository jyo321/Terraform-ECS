# -------------------------
# VPC
# -------------------------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.project_name}-${var.environment}-vpc"
      Environment = var.environment
      Project     = var.project_name
    }
  )
}
# -------------------------
# Internet Gateway
# -------------------------
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.project_name}-${var.environment}-igw"
      Environment = var.environment
      Project     = var.project_name
    }
  )
}

# -------------------------
# Public Subnets
# -------------------------
resource "aws_subnet" "public_az1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_az1_cidr
  availability_zone       = var.availability_zone_1
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.project_name}-${var.environment}-public-subnet-${var.availability_zone_1}"
      Environment = var.environment
      Project     = var.project_name
      Tier        = "Public"
      AZ          = var.availability_zone_1
    }
  )
}

resource "aws_subnet" "public_az2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_az2_cidr
  availability_zone       = var.availability_zone_2
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.project_name}-${var.environment}-public-subnet-${var.availability_zone_2}"
      Environment = var.environment
      Project     = var.project_name
      Tier        = "Public"
      AZ          = var.availability_zone_2
    }
  )
}

# -------------------------
# Private Subnets
# -------------------------
resource "aws_subnet" "private_az1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_az1_cidr
  availability_zone = var.availability_zone_1

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.project_name}-${var.environment}-private-subnet-${var.availability_zone_1}"
      Environment = var.environment
      Project     = var.project_name
      Tier        = "Private"
      AZ          = var.availability_zone_1
    }
  )
}

resource "aws_subnet" "private_az2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_az2_cidr
  availability_zone = var.availability_zone_2

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.project_name}-${var.environment}-private-subnet-${var.availability_zone_2}"
      Environment = var.environment
      Project     = var.project_name
      Tier        = "Private"
      AZ          = var.availability_zone_2
    }
  )
}

# -------------------------
# Elastic IP for NAT Gateway
# -------------------------
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.project_name}-${var.environment}-nat-eip-${var.availability_zone_1}"
      Environment = var.environment
      Project     = var.project_name
      AZ          = var.availability_zone_1
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# -------------------------
# NAT Gateway
# -------------------------
resource "aws_nat_gateway" "main" {
  allocation_id     = aws_eip.nat.id
  subnet_id         = aws_subnet.public_az1.id
  connectivity_type = "public"

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.project_name}-${var.environment}-nat-gw"
      Environment = var.environment
      Project     = var.project_name
      AZ          = var.availability_zone_1
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# -------------------------
# Public Route Table
# -------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.project_name}-${var.environment}-public-rt"
      Environment = var.environment
      Project     = var.project_name
      Tier        = "Public"
    }
  )
}

# -------------------------
# Public Route to Internet Gateway
# -------------------------
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# -------------------------
# Public Route Table Associations
# -------------------------
resource "aws_route_table_association" "public_az1" {
  subnet_id      = aws_subnet.public_az1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_az2" {
  subnet_id      = aws_subnet.public_az2.id
  route_table_id = aws_route_table.public.id
}

# -------------------------
# Private Route Table
# -------------------------
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.project_name}-${var.environment}-private-rt"
      Environment = var.environment
      Project     = var.project_name
      Tier        = "Private"
    }
  )
}

# -------------------------
# Private Route to NAT Gateway
# -------------------------
resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}

# -------------------------
# Private Route Table Associations
# -------------------------
resource "aws_route_table_association" "private_az1" {
  subnet_id      = aws_subnet.private_az1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_az2" {
  subnet_id      = aws_subnet.private_az2.id
  route_table_id = aws_route_table.private.id
}