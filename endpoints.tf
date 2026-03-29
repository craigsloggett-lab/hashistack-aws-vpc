# VPC Endpoint Security Group

locals {
  any_interface_endpoint = (
    var.enable_vpc_endpoints.secretsmanager ||
    var.enable_vpc_endpoints.ec2 ||
    var.enable_vpc_endpoints.kms ||
    var.enable_vpc_endpoints.ssm ||
    var.enable_vpc_endpoints.ssm_messages ||
    var.enable_vpc_endpoints.ec2_messages
  )
}

resource "aws_security_group" "vpc_endpoints" {
  count = local.any_interface_endpoint ? 1 : 0

  name_prefix = "${var.project_name}-vpc-endpoints-"
  description = "Security group for VPC endpoints"
  vpc_id      = module.vpc.vpc_id

  tags = merge(var.common_tags, { Name = "${var.project_name}-vpc-endpoints" })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "vpc_endpoints_https" {
  count = local.any_interface_endpoint ? 1 : 0

  security_group_id = aws_security_group.vpc_endpoints[0].id
  description       = "HTTPS from VPC"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = var.vpc_cidr
}

# Gateway Endpoints

resource "aws_vpc_endpoint" "s3" {
  count = var.enable_vpc_endpoints.s3 ? 1 : 0

  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = module.vpc.private_route_table_ids

  tags = merge(var.common_tags, { Name = "${var.project_name}-s3" })
}

# Interface Endpoints

resource "aws_vpc_endpoint" "secretsmanager" {
  count = var.enable_vpc_endpoints.secretsmanager ? 1 : 0

  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = module.vpc.private_subnets
  security_group_ids  = [aws_security_group.vpc_endpoints[0].id]
  private_dns_enabled = true

  tags = merge(var.common_tags, { Name = "${var.project_name}-secretsmanager" })
}

resource "aws_vpc_endpoint" "ec2" {
  count = var.enable_vpc_endpoints.ec2 ? 1 : 0

  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.ec2"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = module.vpc.private_subnets
  security_group_ids  = [aws_security_group.vpc_endpoints[0].id]
  private_dns_enabled = true

  tags = merge(var.common_tags, { Name = "${var.project_name}-ec2" })
}

resource "aws_vpc_endpoint" "kms" {
  count = var.enable_vpc_endpoints.kms ? 1 : 0

  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.kms"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = module.vpc.private_subnets
  security_group_ids  = [aws_security_group.vpc_endpoints[0].id]
  private_dns_enabled = true

  tags = merge(var.common_tags, { Name = "${var.project_name}-kms" })
}

resource "aws_vpc_endpoint" "ssm" {
  count = var.enable_vpc_endpoints.ssm ? 1 : 0

  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = module.vpc.private_subnets
  security_group_ids  = [aws_security_group.vpc_endpoints[0].id]
  private_dns_enabled = true

  tags = merge(var.common_tags, { Name = "${var.project_name}-ssm" })
}

resource "aws_vpc_endpoint" "ssm_messages" {
  count = var.enable_vpc_endpoints.ssm_messages ? 1 : 0

  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = module.vpc.private_subnets
  security_group_ids  = [aws_security_group.vpc_endpoints[0].id]
  private_dns_enabled = true

  tags = merge(var.common_tags, { Name = "${var.project_name}-ssmmessages" })
}

resource "aws_vpc_endpoint" "ec2_messages" {
  count = var.enable_vpc_endpoints.ec2_messages ? 1 : 0

  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.current.region}.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = module.vpc.private_subnets
  security_group_ids  = [aws_security_group.vpc_endpoints[0].id]
  private_dns_enabled = true

  tags = merge(var.common_tags, { Name = "${var.project_name}-ec2messages" })
}
