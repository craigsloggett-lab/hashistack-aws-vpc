# hashistack-aws-vpc

A standalone Terraform root module that manages a shared AWS VPC for
HashiCorp enterprise products (Vault, Consul, Nomad, TFE).

This module manages the VPC, subnets, routing (internet gateway, NAT gateway,
route tables), and VPC endpoints. Application-specific resources such as
security groups, load balancers, and instances are managed by the individual
product modules.

## Prerequisites

- Terraform `~> 1.7`
- AWS credentials configured
- An [HCP Terraform](https://app.terraform.io) workspace

## Deploying

1. Update `backend.tf` with your HCP Terraform organization, project, and
   workspace name.

2. Copy the example variable file and fill in the required values:

   ```sh
   cp defaults.auto.tfvars.example defaults.auto.tfvars
   ```

3. Enable any additional VPC endpoints needed by your workloads. For example,
   to support Vault (KMS) and TFE (SSM):

   ```hcl
   enable_vpc_endpoints = {
     kms          = true
     ssm          = true
     ssm_messages = true
     ec2_messages = true
   }
   ```

4. Apply the configuration:

   ```sh
   terraform init
   terraform apply
   ```

## Consuming

Product modules that accept an existing VPC (e.g. `terraform-aws-consul-enterprise`,
`terraform-aws-nomad-enterprise`) can consume this VPC's outputs via a
`terraform_remote_state` data source.

```hcl
data "terraform_remote_state" "vpc" {
  backend = "remote"

  config = {
    organization = "<org>"
    workspaces = {
      name = "<workspace>"
    }
  }
}
```

Then pass the outputs to the product module's `existing_vpc` variable:

```hcl
existing_vpc = {
  vpc_id             = data.terraform_remote_state.vpc.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids
  public_subnet_ids  = data.terraform_remote_state.vpc.outputs.public_subnet_ids
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 6.43.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.43.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 6.6.1 |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Tags to apply to all resources. | `map(string)` | `{}` | no |
| <a name="input_enable_vpc_endpoints"></a> [enable\_vpc\_endpoints](#input\_enable\_vpc\_endpoints) | VPC endpoints to provision. S3, Secrets Manager, and EC2 are enabled by default. | <pre>object({<br/>    s3             = optional(bool, true)<br/>    secretsmanager = optional(bool, true)<br/>    ec2            = optional(bool, true)<br/>    kms            = optional(bool, false)<br/>    ssm            = optional(bool, false)<br/>    ssm_messages   = optional(bool, false)<br/>    ec2_messages   = optional(bool, false)<br/>  })</pre> | `{}` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name prefix for all resources. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region to deploy into. | `string` | n/a | yes |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR block for the VPC. | `string` | `"10.0.0.0/16"` | no |
| <a name="input_vpc_private_subnets"></a> [vpc\_private\_subnets](#input\_vpc\_private\_subnets) | List of private subnet CIDR blocks. | `list(string)` | <pre>[<br/>  "10.0.1.0/24",<br/>  "10.0.2.0/24",<br/>  "10.0.3.0/24"<br/>]</pre> | no |
| <a name="input_vpc_public_subnets"></a> [vpc\_public\_subnets](#input\_vpc\_public\_subnets) | List of public subnet CIDR blocks. | `list(string)` | <pre>[<br/>  "10.0.101.0/24",<br/>  "10.0.102.0/24",<br/>  "10.0.103.0/24"<br/>]</pre> | no |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_security_group.vpc_endpoints](https://registry.terraform.io/providers/hashicorp/aws/6.43.0/docs/resources/security_group) | resource |
| [aws_vpc_endpoint.ec2](https://registry.terraform.io/providers/hashicorp/aws/6.43.0/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.ec2_messages](https://registry.terraform.io/providers/hashicorp/aws/6.43.0/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.kms](https://registry.terraform.io/providers/hashicorp/aws/6.43.0/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.s3](https://registry.terraform.io/providers/hashicorp/aws/6.43.0/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.secretsmanager](https://registry.terraform.io/providers/hashicorp/aws/6.43.0/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.ssm](https://registry.terraform.io/providers/hashicorp/aws/6.43.0/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.ssm_messages](https://registry.terraform.io/providers/hashicorp/aws/6.43.0/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_security_group_ingress_rule.vpc_endpoints_https](https://registry.terraform.io/providers/hashicorp/aws/6.43.0/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/6.43.0/docs/data-sources/availability_zones) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/6.43.0/docs/data-sources/region) | data source |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_availability_zones"></a> [availability\_zones](#output\_availability\_zones) | Availability zones used by the VPC. |
| <a name="output_nat_gateway_public_ip"></a> [nat\_gateway\_public\_ip](#output\_nat\_gateway\_public\_ip) | Public IP of the NAT gateway. |
| <a name="output_private_route_table_ids"></a> [private\_route\_table\_ids](#output\_private\_route\_table\_ids) | IDs of the private route tables. |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | IDs of the private subnets. |
| <a name="output_public_route_table_ids"></a> [public\_route\_table\_ids](#output\_public\_route\_table\_ids) | IDs of the public route tables. |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | IDs of the public subnets. |
| <a name="output_vpc_cidr"></a> [vpc\_cidr](#output\_vpc\_cidr) | CIDR block of the VPC. |
| <a name="output_vpc_endpoint_security_group_id"></a> [vpc\_endpoint\_security\_group\_id](#output\_vpc\_endpoint\_security\_group\_id) | ID of the security group attached to VPC interface endpoints. |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | ID of the VPC. |
<!-- END_TF_DOCS -->
