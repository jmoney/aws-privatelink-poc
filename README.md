# private-link-poc

This is a POC to demonstrate an issue with AWS PrivateLink.  The issue is that when the security group on the network load balancer for this provider is locked down to the consumer ip addresses there is a gateway timeout through a LB.  The security group of the NLB needs to be set further upstream to the source IP addresses, in this case the private IPs of the ALB, rather than the consumer IPs.

## Setup

```bash
terraform init
terraform apply -var input_provider_ingress="alb"
```

This will create a public ALB pointed at a VPC endpoint mapped to an NLB via a VPC Endpoint Service.  The NLB is pointed at an instance running a simple echo server.  The security group on the NLB is locked down to the ALB private IPs.

```bash
terraform init
terraform apply -var input_provider_ingress="consumers"
```

This will create a public ALB pointed at a VPC endpoint mapped to an NLB via a VPC Endpoint Service.  The NLB is pointed at an instance running a simple echo server.  The security group on the NLB is locked down to the consumer private IPs.

## Testing

To test this POC, you can run the following command:

```bash
curl -s -v "http://$(terraform output -json | jq -r .public_lb_dns)/http"
```

To log into the instance you can use session manager:

```bash
aws ssm start-session --target $(terraform output -json | jq -r .echo_server_id)
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 5.40.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.40.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_consumer"></a> [consumer](#module\_consumer) | ./modules/consumer | n/a |
| <a name="module_consumer_network"></a> [consumer\_network](#module\_consumer\_network) | ./modules/network_segment | n/a |
| <a name="module_echo_server"></a> [echo\_server](#module\_echo\_server) | ./modules/echo_server | n/a |
| <a name="module_provider"></a> [provider](#module\_provider) | ./modules/provider | n/a |
| <a name="module_provider_network"></a> [provider\_network](#module\_provider\_network) | ./modules/network_segment | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_lb.public_lb](https://registry.terraform.io/providers/hashicorp/aws/5.40.0/docs/resources/lb) | resource |
| [aws_lb_listener.public_lb](https://registry.terraform.io/providers/hashicorp/aws/5.40.0/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.public_lb](https://registry.terraform.io/providers/hashicorp/aws/5.40.0/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group_attachment.consumers](https://registry.terraform.io/providers/hashicorp/aws/5.40.0/docs/resources/lb_target_group_attachment) | resource |
| [aws_security_group.public_lb](https://registry.terraform.io/providers/hashicorp/aws/5.40.0/docs/resources/security_group) | resource |
| [aws_security_group_rule.private_link_provider_ingress](https://registry.terraform.io/providers/hashicorp/aws/5.40.0/docs/resources/security_group_rule) | resource |
| [aws_network_interface.alb_eni](https://registry.terraform.io/providers/hashicorp/aws/5.40.0/docs/data-sources/network_interface) | data source |
| [aws_network_interface.consumer_network_interface](https://registry.terraform.io/providers/hashicorp/aws/5.40.0/docs/data-sources/network_interface) | data source |
| [aws_network_interfaces.alb_enis](https://registry.terraform.io/providers/hashicorp/aws/5.40.0/docs/data-sources/network_interfaces) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_provider_ingress"></a> [provider\_ingress](#input\_provider\_ingress) | Where to grab the IPs for the NLB provider security group. | `string` | `"alb"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_consumer_ips"></a> [consumer\_ips](#output\_consumer\_ips) | IP addresses of the consumer network interfaces |
| <a name="output_echo_server_id"></a> [echo\_server\_id](#output\_echo\_server\_id) | value of the echo server's instance ID |
| <a name="output_private_link_vpcs"></a> [private\_link\_vpcs](#output\_private\_link\_vpcs) | VPC IDs of the provider and consumer networks |
| <a name="output_provider_service_name"></a> [provider\_service\_name](#output\_provider\_service\_name) | value of the provider service name |
| <a name="output_public_lb_dns"></a> [public\_lb\_dns](#output\_public\_lb\_dns) | value of the public load balancer's DNS name |
