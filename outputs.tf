# output "vpc_id" {
#   description = "The ID of the VPC"
#   value       = concat(module.vpc.this.*.id, [""])[0]
# }

# output "private_subnets" {
#   description = "List of IDs of private subnets"
#   value       = module.vpc.private.*.id
# }

# output "public_subnets" {
#   description = "List of IDs of public subnets"
#   value       = module.vpc.public.*.id
# }

output "lb_dns_name" {
  value = aws_lb.app.dns_name
}