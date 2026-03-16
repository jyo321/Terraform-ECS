output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = aws_vpc.main.cidr_block
}

output "vpc_arn" {
  description = "VPC ARN"
  value       = aws_vpc.main.arn
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = [aws_subnet.public_az1.id, aws_subnet.public_az2.id]
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = [aws_subnet.private_az1.id, aws_subnet.private_az2.id]
}

output "public_subnet_az1_id" {
  description = "Public subnet ID in AZ1"
  value       = aws_subnet.public_az1.id
}

output "public_subnet_az2_id" {
  description = "Public subnet ID in AZ2"
  value       = aws_subnet.public_az2.id
}

output "private_subnet_az1_id" {
  description = "Private subnet ID in AZ1"
  value       = aws_subnet.private_az1.id
}

output "private_subnet_az2_id" {
  description = "Private subnet ID in AZ2"
  value       = aws_subnet.private_az2.id
}

output "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks"
  value       = [aws_subnet.public_az1.cidr_block, aws_subnet.public_az2.cidr_block]
}

output "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks"
  value       = [aws_subnet.private_az1.cidr_block, aws_subnet.private_az2.cidr_block]
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.main.id
}

output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = aws_nat_gateway.main.id
}

output "nat_eip_public_ip" {
  description = "NAT Gateway Elastic IP address"
  value       = aws_eip.nat.public_ip
}

output "nat_eip_allocation_id" {
  description = "NAT Gateway EIP allocation ID"
  value       = aws_eip.nat.id
}

output "public_route_table_id" {
  description = "Public route table ID"
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "Private route table ID"
  value       = aws_route_table.private.id
}

output "availability_zones" {
  description = "List of availability zones used"
  value       = [var.availability_zone_1, var.availability_zone_2]
}

output "network_summary" {
  description = "Network configuration summary"
  value = {
    vpc_id             = aws_vpc.main.id
    vpc_cidr           = aws_vpc.main.cidr_block
    environment        = var.environment
    project            = var.project_name
    availability_zones = [var.availability_zone_1, var.availability_zone_2]
    public_subnets     = 2
    private_subnets    = 2
    nat_gateways       = 1
  }
}