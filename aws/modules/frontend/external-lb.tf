################################################################################
# Load Balancer
################################################################################
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name = "3-tier-alb"

  load_balancer_type = "application"

  vpc_id          = module.networking.vpc_id
  subnets         = module.networking.public_subnets
  security_groups = [aws_security_group.alb_layer_sg.id]

#   access_logs = {
#     bucket = aws_s3_bucket.alb_access_log.id
#   }

  target_groups = [
    {
      name_prefix      = "3-tier-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      stickiness = {
        enabled         = true
        cookie_duration = 28800
        type            = "lb_cookie"
      }
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = {
      Terraform = "true"
      Environment = "dev"
    }
}