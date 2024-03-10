variable "subnet_ids" {
    description = "The subnet IDs for the load balancer"
    type        = list(string)
}

variable "instance_ip" {
    description = "The IP address of the instance to attach to the load balancer"
    type        = string
}