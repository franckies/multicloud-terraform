################################################################################
# Autoscaling group
################################################################################
module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 4.0"

  # Autoscaling group
  name = "3-tier-asg"

  min_size                  = 1
  max_size                  = 2
  desired_capacity          = 1
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  vpc_zone_identifier       = module.vpc.private_subnets

  instance_refresh = {
    strategy = "Rolling"
    preferences = {
      min_healthy_percentage = 0
    }
    triggers = ["tag"]
  }

  # Launch template
  lt_name                = "3-tier-asg"
  description            = "3-tier-asg"
  update_default_version = true

  use_lt                   = true
  create_lt                = true
  iam_instance_profile_arn = aws_iam_instance_profile.3-tier_profile.arn
  image_id                 = data.aws_ami.amazon_linux2.id
  instance_type            = var.asg_instance_type
  ebs_optimized            = true
  enable_monitoring        = true

  block_device_mappings = [
    {
      # Root volume
      device_name = "/dev/xvda"
      no_device   = 0
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_size           = 30
        volume_type           = "gp2"
      }
    }
  ]

  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 32
  }

  network_interfaces = [
    {
      delete_on_termination = true
      description           = "eth0"
      device_index          = 0
      security_groups       = [aws_security_group.app_layer_sg.id]
    }
  ]

  target_group_arns = module.alb.target_group_arns
  user_data_base64 = base64encode(templatefile("./scripts/userdata.sh.tpl", {
    efs_endpoint      = aws_efs_file_system.3-tier_efs.dns_name
    efs_id            = aws_efs_file_system.3-tier_efs.id
    database_name     = var.rds_database_name
    database_endpoint = module.db.this_rds_cluster_endpoint
    database_username = var.rds_username
    database_password = module.db.this_rds_cluster_master_password
    lb_endpoint       = module.alb.lb_dns_name
  }))
}