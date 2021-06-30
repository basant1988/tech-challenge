output "vpc_id" {
  description = "VPC Id"
  value       = aws_vpc.poc_vpc.id
}

output "vpc_arn" {
  description = "ARN of VPC"
  value       = aws_vpc.poc_vpc.arn
}

output "vpc_cidr_block" {
  description = "CIDR block of VPC"
  value       = aws_vpc.poc_vpc.cidr_block
}

output "private_subnets" {
  description = "List of private subnet ids"
  value       = aws_subnet.private_subnet.*.id
}

output "private_subnets_cidr_blocks" {
  description = "List of private subnets cidr blocks"
  value       = aws_subnet.private_subnet.*.cidr_block
}

output "public_subnets" {
  description = "List of public subnets ids"
  value       = aws_subnet.public_subnet.*.id
}

output "public_subnets_cidr_blocks" {
  description = "List of public subnets cidr blocks"
  value       = aws_subnet.public_subnet.*.cidr_block
}

output "db_subnets" {
  description = "List of db subnets ids"
  value       = aws_subnet.db_subnet.*.id
}

output "db_subnets_cidr_blocks" {
  description = "List of database subnets cidr_blocks"
  value       = aws_subnet.db_subnet.*.cidr_block
}
