variable "project_name" {
  description = "Name prefix for all resources."
  type        = string

  validation {
    condition     = length(var.project_name) <= 16
    error_message = "The project_name must be 16 characters or fewer."
  }
}

variable "region" {
  description = "AWS region to deploy into."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_private_subnets" {
  description = "List of private subnet CIDR blocks."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "vpc_public_subnets" {
  description = "List of public subnet CIDR blocks."
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "enable_vpc_endpoints" {
  description = "VPC endpoints to provision. S3, Secrets Manager, and EC2 are enabled by default."
  type = object({
    s3             = optional(bool, true)
    secretsmanager = optional(bool, true)
    ec2            = optional(bool, true)
    kms            = optional(bool, false)
    ssm            = optional(bool, false)
    ssm_messages   = optional(bool, false)
    ec2_messages   = optional(bool, false)
  })
  default = {}
}

variable "common_tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}
