variable "provider_ingress" {
    description = "Where to grab the IPs for the NLB provider security group."
    validation {
        condition = contains(["alb", "consumers"], var.provider_ingress)
        error_message = "Options include alb or consumers"
    }
    type        = string
    default     = "alb"
}