# Input variable definitions
variable "region" {
  description = "Region to configure the infra"
  type = string
  default = "ap-south-1"
}

variable "availability_zones" {
  description = "A list of availability zones"
  type        = list(string)
  default     = []
}

variable "vpc-name" {
  description = "Name of the VPC"
  type = string
  default = "poc-vpc"
}

variable "vpc-cidr" {
  description = "VPC cider range "
  type = string
  default = "0.0.0.0/0"
}

variable "public_subnets" {
  description = "List of public subnets"
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "List of private subnets"
  type        = list(string)
  default     = []
}

variable "db_subnets" {
  description = "List of database subnets"
  type        = list(string)
  default     = []
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
  default     = {}
}