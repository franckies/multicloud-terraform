################################################################################
# Security groups for frontend
################################################################################
resource "aws_security_group" "frontend-sg" {
  name = "${var.prefix_name}-frontend-sg"

  description = "Allow HTTP, HTTPS and SSH connection from Load Balancer & Bastion"
  vpc_id      = var.vpc_id

  # Allow inboud communication only for external lb and bastion
  ingress {
    from_port       = var.http_port
    to_port         = var.http_port
    protocol        = "tcp"
    security_groups = [aws_security_group.wordpress-lb-sg.id]
  }

  ingress {
    from_port       = var.https_port
    to_port         = var.https_port
    protocol        = "tcp"
    security_groups = [aws_security_group.wordpress-lb-sg.id]
  }

  ingress {
    from_port       = var.ssh_port
    to_port         = var.ssh_port
    protocol        = "tcp"
    security_groups = [module.bastion.security_group_id]
  }

  # Allow all outbound communication
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
    Name        = "${var.prefix_name}-servers-sg"
    Terraform   = "true"
    Environment = "dev"
  }
}
