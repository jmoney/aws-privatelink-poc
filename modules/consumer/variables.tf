variable "vpc_id" {
    description = "The VPC ID for the consumer"
    type        = string
}

variable "service_name" {
    description = "The service name for the VPC endpoint"
    type        = string
}

variable "subnet_ids" {
    description = "The subnet IDs for the VPC endpoint"
    type        = list(string)
}