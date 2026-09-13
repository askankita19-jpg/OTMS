output "vpc_id" {
  description = "OTMS VPC ID."

  value = module.network.vpc_id
}


output "public_subnet_ids" {
  description = "Public subnet IDs used by the ALB."

  value = module.network.public_subnet_ids
}


output "private_app_subnet_ids" {
  description = "Private application subnet IDs."

  value = module.network.private_app_subnet_ids
}


output "private_database_subnet_id" {
  description = "Private database subnet ID."

  value = module.network.private_database_subnet_id
}


output "alb_dns_name" {
  description = "ALB DNS name."

  value = module.network.load_balancer_dns_name
}


output "application_asg_names" {
  description = "Application ASG names."

  value = {
    for name, service in module.application :
    name => service.autoscaling_group_name
  }
}


output "database_instances" {
  description = "Database EC2 details for Ansible."

  value = {
    for name, db in module.database :
    name => {
      instance_id = db.instance_id
      private_ip  = db.private_ip
    }
  }
}
