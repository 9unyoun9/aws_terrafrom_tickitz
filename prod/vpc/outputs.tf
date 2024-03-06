output "SG-alb-name" {
  value       = module.webserver_cluster.alb_security_group_name
}

output "SG-instance-name" {
  value       = module.webserver_cluster.instance_security_group_name
}

output "alb_dns_name" {
  value       = module.webserver_cluster.alb_dns_name
  description = "The domain name of the load balancer"
}

