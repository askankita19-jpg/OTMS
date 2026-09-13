output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_app_subnet_ids" {
  value = aws_subnet.private_app[*].id
}

output "private_database_subnet_id" {
  value = aws_subnet.private_database.id
}

output "application_security_group_id" {
  value = aws_security_group.application.id
}

output "database_security_group_ids" {
  value = {
    postgresql = aws_security_group.postgresql.id
    redis      = aws_security_group.redis.id
    scylladb   = aws_security_group.scylladb.id
  }
}

output "load_balancer_dns_name" {
  value = aws_lb.this.dns_name
}

output "load_balancer_arn" {
  value = aws_lb.this.arn
}

output "application_listener_arn" {
  value = var.enable_https
    ? aws_lb_listener.https[0].arn
    : aws_lb_listener.http[0].arn
}
