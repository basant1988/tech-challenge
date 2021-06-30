resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

locals {
  dbcredential = {
    username     = "admin",
    password     = random_password.password.result
  }
}

resource "aws_secretsmanager_secret" "dbcredential" {
   name = "db-credential"
   recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "dbcredversion" {
  secret_id     = aws_secretsmanager_secret.dbcredential.id
  secret_string = jsonencode(local.dbcredential)
}

data "aws_secretsmanager_secret" "dbcredential" {
  arn = aws_secretsmanager_secret.dbcredential.arn
}

data "aws_secretsmanager_secret_version" "db_secret" {
  secret_id = data.aws_secretsmanager_secret.dbcredential.arn
}

locals {
  db_creds = jsondecode(data.aws_secretsmanager_secret_version.db_secret.secret_string)
}

# Security group to allow api servers to connect too DB
module "db-server-sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "db-sg"
  description = "Security group db-server to open port 80"
  vpc_id      = module.vpc.vpc_id

  ingress_with_source_security_group_id = [
    {
      rule                     = "mysql-tcp"
      source_security_group_id = module.backend-server-sg.security_group_id
    },
  ]
  tags = merge(
    {
      "Name" = "db-server-sg"
    },
    var.tags,
  )
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 3.0"

  identifier = "pocdb"

  engine            = "mysql"
  engine_version    = var.db-engine-version
  instance_class    = var.db-instance-class
  allocated_storage = var.db-storage

  name     = "pocdb"
  username = local.db_creds["username"]
  password = local.db_creds["password"]
  port     = var.db-instance-port

  vpc_security_group_ids = [module.db-server-sg.security_group_id]

  maintenance_window = var.db-maintenance-window
  backup_window      = var.db-backup-window

  monitoring_interval = "30"
  monitoring_role_name = "POCRDSMonitoringRole"
  create_monitoring_role = true
  backup_retention_period = backup-retention-period
  multi_az = var.multi-az
  tags = var.tags
  subnet_ids = module.vpc.db_subnets
  family = var.db-family
  major_engine_version = var.db-major-engine-version
  deletion_protection = true
}

