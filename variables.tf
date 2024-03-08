variable "provider_ingress_cidr_block" {
    description = "The CIDR block for the ingress rule of the provider load balancer"
    type        = string
    default = "10.0.0.0/8"
}