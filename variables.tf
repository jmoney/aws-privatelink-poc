variable "open_provider_ingress" {
    description = "Whether or not to open the provider ingress rule or lock down to consumer ips"
    type        = bool
    default     = true
}