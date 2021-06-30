output "vpc_id" {
  description = "VPC Id"
  value       = module.vpc.vpc_id
}

output "vpc_arn" {
  description = "ARN of VPC"
  value       = module.vpc.vpc_arn
}

output "vpc_cidr_block" {
  description = "CIDR block of VPC"
  value       = module.vpc.vpc_cidr_block
}

output "private_subnets" {
  description = "List of private subnet ids"
  value       = module.vpc.private_subnets
}

output "private_subnets_cidr_blocks" {
  description = "List of private subnets cidr blocks"
  value       = module.vpc.private_subnets_cidr_blocks
}

output "public_subnets" {
  description = "List of public subnets ids"
  value       = module.vpc.public_subnets
}

output "public_subnets_cidr_blocks" {
  description = "List of public subnets cidr blocks"
  value       = module.vpc.public_subnets_cidr_blocks
}

output "db_subnets" {
  description = "List of db subnets ids"
  value       = module.vpc.db_subnets
}

output "db_subnets_cidr_blocks" {
  description = "List of database subnets cidr_blocks"
  value       = module.vpc.db_subnets_cidr_blocks
}

output "web_lb_arn" {
  description = "Web load balancer ARN"
  value       = aws_lb.web-lb.arn
}

output "web_lb_dns" {
  description = "Web load balancer DNS"
  value       = aws_lb.web-lb.dns_name
}

output "db_instance_address" {
  description = "address of the RDS instance"
  value       = module.db.db_instance_address
}

output "db_instance_arn" {
  description = "ARN of the RDS instance"
  value       = module.db.db_instance_arn
}

output "db_instance_endpoint" {
  description = "connection endpoint"
  value       = module.db.db_instance_endpoint
}

output "db_instance_id" {
  description = "RDS instance ID"
  value       = module.db.db_instance_id
}

output "db_instance_name" {
  description = "database name"
  value       = module.db.db_instance_name
}
