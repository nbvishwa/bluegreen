locals {
    region = "ap-south-1"
    vpc_name = "bg-vpc"
    vpc_cidr = "10.0.0.0/16"
    azs = ["ap-south-1a", "ap-south-1b"]
    public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
    private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]

    ubuntu_ami = "ami-0567e0d2b4b2169ae"

    traffic_dist_map = {
    blue = {
      blue  = 100
      green = 0
    }
    blue-90 = {
      blue  = 90
      green = 10
    }
    split = {
      blue  = 50
      green = 50
    }
    green-90 = {
      blue  = 10
      green = 90
    }
    green = {
      blue  = 0
      green = 100
    }
  }

}

provider aws {
    region = local.region
}

module "vpc" {

  source = "terraform-aws-modules/vpc/aws"

  name = local.vpc_name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets

  enable_nat_gateway = true
  enable_vpn_gateway = true
  single_nat_gateway = true

  tags = {
    Name = "blue-green"
  }
}

//Security group
resource "aws_security_group" "web" {
    name = "web-sg"
    description = "security group for web servers"
    vpc_id = module.vpc.vpc_id

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
}

//ALB
resource "aws_lb" "app" {
    name = "app-lb"
    internal = false
    load_balancer_type = "application"
    subnets = module.vpc.public_subnets
    security_groups = [aws_security_group.web.id]
}

//Load balancer listener
resource "aws_lb_listener" "app" {
    load_balancer_arn = aws_lb.app.arn
    port = "80"
    protocol = "HTTP"

    default_action {
        type = "forward"
        # target_group_arn = aws_lb_target_group.blue.arn
        forward{
            target_group {
                arn    = aws_lb_target_group.blue.arn
                weight = lookup(local.traffic_dist_map[var.traffic_distribution], "blue", 100)
            }

            target_group {
                arn    = aws_lb_target_group.green.arn
                weight = lookup(local.traffic_dist_map[var.traffic_distribution], "green", 0)
            }

            stickiness {
                enabled  = false
                duration = 1
            }
        }
        
    }

}

