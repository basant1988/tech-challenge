module "vpc" {
  source = "./modules/vpc"
  availability_zones = var.availability_zones
  vpc-name = var.vpc-name
  vpc-cidr = var.vpc-cidr
  public_subnets = var.public_subnets
  private_subnets = var.private_subnets
  db_subnets = var.db_subnets
  public_subnet_name_suffix = var.public_subnet_name_suffix
  private_subnet_name_suffix = var.private_subnet_name_suffix
  db_subnet_name_suffix = var.db_subnet_name_suffix
  tags = var.tags
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name = "name"

    values = [
      "amzn2-ami-hvm-*-x86_64-gp2",
    ]
  }

  filter {
    name = "owner-alias"

    values = [
      "amazon",
    ]
  }
}

locals {
  web_user_data = <<-EOT
  #!/bin/bash -xe
  cd /tmp
  sudo yum update -y
  sudo yum install httpd -y
  echo "Hello from the EC2 instance $(hostname -f)." > /var/www/html/index.html
  sudo systemctl start httpd
  sudo systemctl enable httpd
  chkconfig httpd on
  EOT

  backend_user_data = <<-EOT
  #!/bin/bash -xe
  sudo yum update -y
  sudo yum install git -y
  git clone https://github.com/basant1988/python-sample-api.git
  cd python-sample-api
  pip install -r requirements.txt
  sudo nohup python api.py &
  EOT
}

module "web-server-sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "web-sg"
  description = "Security group webserver to open port 80"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks      = ["0.0.0.0/0"]
  ingress_rules            = ["http-80-tcp"]
  egress_rules             = ["all-all"]
  tags = merge(
    {
      "Name" = "web-server-sg"
    },
    var.tags,
  )
}

module "alb-sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "alb-sg"
  description = "Security group for alb to open port 80"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks      = ["0.0.0.0/0"]
  ingress_rules            = ["http-80-tcp"]
  egress_rules             = ["all-all"]
  tags = merge(
    {
      "Name" = "web-alb-sg"
    },
    var.tags,
  )
}

module "backend-alb-sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "backend-alb-sg"
  description = "Security group for backend alb to open port 8080"
  vpc_id      = module.vpc.vpc_id

  egress_rules             = ["all-all"]
  ingress_with_source_security_group_id = [
    {
      rule                     = "http-8080-tcp"
      source_security_group_id = module.web-server-sg.security_group_id
    },
  ]
  tags = merge(
    {
      "Name" = "backend-alb-sg"
    },
    var.tags,
  )
}

module "backend-server-sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "backend-sg"
  description = "Security group backend-server to open port 8080 and 22"
  vpc_id      = module.vpc.vpc_id
  egress_rules             = ["all-all"]
  ingress_with_source_security_group_id = [
    {
      rule                     = "http-8080-tcp"
      source_security_group_id = module.backend-alb-sg.security_group_id
    },
  ]
  tags = merge(
    {
      "Name" = "backend-server-sg"
    },
    var.tags,
  )
}

# IAM role and Instance profile for ec2
resource "aws_iam_role" "ssm-role-ec2" {
  name                = "SSMRoleForEc2"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
}

resource "aws_iam_instance_profile" "ec2-instance-profile" {
  name  = "Ec2InstanceProfilePoc"
  role  = aws_iam_role.ssm-role-ec2.name
}

# Web server ASG with Launch Template

module "web-asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "4.4.0"
  name = var.web-asg-name

  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1
  health_check_type         = "EC2"
  vpc_zone_identifier       = module.vpc.public_subnets

  # Launch configuration
  lc_name   = var.web-launch-config-name
  use_lc    = true
  create_lc = true

  image_id          = data.aws_ami.amazon_linux.image_id
  instance_type     = var.web-instance-type
  user_data         = local.web_user_data
  iam_instance_profile_name = aws_iam_instance_profile.ec2-instance-profile.name
  security_groups             = [module.web-server-sg.security_group_id]
  associate_public_ip_address = true

  target_group_arns = [aws_lb_target_group.web-server-tg.id]
  root_block_device = [
    {
      delete_on_termination = true
      encrypted             = true
      volume_size           = var.web-storage
      volume_type           = "gp2"
    },
  ]

  tags = [
	{
      key                 = "Name"
      value               = "web-server"
      propagate_at_launch = true
    },
    {
      key                 = "Type"
      value               = "Assignment"
      propagate_at_launch = true
    },
    {
      key                 = "Organization"
      value               = "KPMG"
      propagate_at_launch = true
    },
  ]
}

# Web Server Target Group
resource "aws_lb_target_group" "web-server-tg" {
  name     = "web-server-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
  stickiness {
    type            = "lb_cookie"
    enabled         = var.stickyness-enabled
  }
  health_check {
    port    = 80
    path    = "/"
  }
}

# Attaching web server target group to Web Server Autoscaling Group
resource "aws_autoscaling_attachment" "web-target-attachment" {
  autoscaling_group_name = module.web-asg.autoscaling_group_name
  alb_target_group_arn   = aws_lb_target_group.web-server-tg.id
}

# Web server public facing Load balancer
resource "aws_lb" "web-lb" {
  name               = "web-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.alb-sg.security_group_id]
  subnets            = module.vpc.public_subnets

  tags = merge(
    {
      "Name" = "web-public-lb"
    },
    var.tags,
  )
}
# HTTP web server listener
resource "aws_lb_listener" "web-http-listener" {
  load_balancer_arn = aws_lb.web-lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-server-tg.arn
  }
}

# Backend server ASG with Launch Template

module "backend-asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "4.4.0"
  name = var.backend-asg-name

  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1
  health_check_type         = "EC2"
  vpc_zone_identifier       = module.vpc.private_subnets

  # Launch configuration
  lc_name   = var.backend-launch-config-name
  use_lc    = true
  create_lc = true

  image_id          = data.aws_ami.amazon_linux.image_id
  instance_type     = var.backend-instance-type
  user_data         = local.backend_user_data
  iam_instance_profile_name = aws_iam_instance_profile.ec2-instance-profile.name
  security_groups             = [module.backend-server-sg.security_group_id]

  target_group_arns = [aws_lb_target_group.backend-tg.arn]
  root_block_device = [
    {
      delete_on_termination = true
      encrypted             = true
      volume_size           = var.backend-storage
      volume_type           = "gp2"
    },
  ]

  tags = [
	{
      key                 = "Name"
      value               = "backend-server"
      propagate_at_launch = true
    },
    {
      key                 = "Type"
      value               = "Assignment"
      propagate_at_launch = true
    },
    {
      key                 = "Organization"
      value               = "KPMG"
      propagate_at_launch = true
    },
  ]
}

# Backend Server Target Group
resource "aws_lb_target_group" "backend-tg" {
  name     = "backend-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
  health_check {
    enabled = true
    port    = 8080
    path    = "/"
    protocol = "HTTP"
    unhealthy_threshold = 3
    healthy_threshold = 3
  }
}

# Web server public facing Load balancer
resource "aws_lb" "backend-lb" {
  name               = "backend-internal-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [module.backend-alb-sg.security_group_id]
  subnets            = module.vpc.private_subnets

  tags = merge(
    {
      "Name" = "backend-internal-lb"
    },
    var.tags,
  )
}
# HTTP web server listener
resource "aws_lb_listener" "backend-http-listener" {
  load_balancer_arn = aws_lb.backend-lb.arn
  port              = "8080"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend-tg.arn
  }
}
