################################################################################
# Security groups for External Load Balancer
################################################################################
resource "aws_security_group" "counter-app-elb-sg" {
  name = "${var.prefix_name}-elb-sg"

  description = "Allow HTTP connection from everywhere"
  vpc_id      = var.vpc_id

  # Accept from everywhere
  ingress {
    from_port        = var.http_port
    to_port          = var.http_port
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port = var.http_port
    to_port   = var.http_port
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = var.https_port
    to_port   = var.https_port
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

    tags = {
    Name        = "${var.prefix_name}-elb-sg"
    Terraform   = "true"
    Environment = "dev"
  }
}

################################################################################
# External Load Balancer
################################################################################
resource "aws_alb" "counter-app-eloadbalancer" {

  name               = "${var.prefix_name}-eloadbalancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.counter-app-elb-sg.id]
  subnets            = var.public_subnets
  tags = {
      Terraform = "true"
      Environment = "dev"
    }
}

resource "aws_alb_listener" "counter-app-elb-listener" {
  load_balancer_arn = aws_alb.counter-app-iloadbalancer.arn
  port              = var.http_port
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.counter-app-elb-target-group.arn
  }
}

resource "aws_alb_target_group" "counter-app-elb-target-group" {
  name     = "${var.prefix_name}-target-group"
  port     = var.http_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {    
    healthy_threshold   = 3    
    unhealthy_threshold = 10    
    timeout             = 5    
    interval            = 10    
    port                = 80 
  }
  tags = {
      Terraform = "true"
      Environment = "dev"
    }
}