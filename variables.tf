variable "region" {
  description = "Region to configure the infra"
  type = string
  default = "eu-west-1"
}

variable "availability_zones" {
  description = "A list of availability zones"
  type        = list(string)
  default     = ["eu-west-1a","eu-west-1b","eu-west-1c"]
}

variable "vpc-name" {
  description = "Name of the VPC"
  type = string
  default = "poc-vpc"
}

variable "vpc-cidr" {
  description = "VPC cider range "
  type = string
  default = "10.13.0.0/16"
}

variable "public_subnets" {
  description = "List of public subnets"
  type        = list(string)
  default     = ["10.13.24.0/25","10.13.24.128/25","10.13.25.0/25"]
}

variable "private_subnets" {
  description = "List of private subnets"
  type        = list(string)
  default     = ["10.13.25.128/25","10.13.26.0/25","10.13.26.128/25"]
}

variable "db_subnets" {
  description = "List of database subnets"
  type        = list(string)
  default     = ["10.13.27.0/25","10.13.27.128/25","10.13.28.0/25"]
}

variable "public_subnet_name_suffix" {
  description = "Suffix to append to public subnets name"
  type        = string
  default     = "public"
}

variable "private_subnet_name_suffix" {
  description = "Suffix to append to private subnets name"
  type        = string
  default     = "private"
}

variable "db_subnet_name_suffix" {
  description = "Suffix to append to db subnets name"
  type        = string
  default     = "db"
}

variable "tags" {
  description = "Tags to set"
  type        = map(string)
  default = {
    Type   = "Assignment"
    # Organization = "KPMG"
    Owner = "Basant"
  }
}

variable "web-launch-config-name" {
  description = "Name of web launch config"
  type        = string
  default     = "web-launch-config"
}

variable "backend-launch-config-name" {
  description = "Name of backend launch config"
  type        = string
  default     = "backend-launch-config"
}

variable "web-asg-name" {
  description = "Name of web ASG"
  type        = string
  default     = "web-asg"
}

variable "backend-asg-name" {
  description = "Name of backend ASG"
  type        = string
  default     = "backend-asg"
}

variable "web-instance-type" {
  description = "The type of web instance"
  type        = string
  default     = "t2.micro"
}

variable "backend-instance-type" {
  description = "The type of backend instance"
  type        = string
  default     = "t2.micro"
}

variable "web-storage" {
  description = "disk size for web server"
  type        = string
  default     = "20"
}

variable "backend-storage" {
  description = "disk size for backend server"
  type        = string
  default     = "20"
}

variable "stickyness-enabled" {
  description = "Set stickiness enabled or disabled"
  type        = bool
  default     = true
}

variable "db-storage" {
  description = "disk size for db server"
  type        = string
  default     = "20"
}

variable "db-instance-class" {
  description = "Db instance class"
  type        = string
  default     = "db.m6g.large"
}

variable "db-instance-port" {
  description = "DB instance PORT"
  type        = string
  default     = "3306"
}

variable "db-family" {
  description = "DB mysql family"
  type        = string
  default     = "mysql8.0"
}

variable "db-engine-version" {
  description = "DB mysql engine version"
  type        = string
  default     = "8.0.21"
}

variable "db-major-engine-version" {
  description = "DB mysql major engine version"
  type        = string
  default     = "8.0"
}

variable "db-maintenance-window" {
  description = "DB maintenance window"
  type        = string
  default     = "Sun:00:00-Sun:03:00"
}

variable "db-backup-window" {
  description = "DB backup window to take backup"
  type        = string
  default     = "03:00-06:00"
}

variable "backup-retention-period" {
  description = "DB backup retention period"
  type        = number
  default     = 30
}

variable "multi-az" {
  description = "Multi AZ setting"
  type        = bool
  default     = true
}
