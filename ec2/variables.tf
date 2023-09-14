variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "Default VPC Id"
  type        = string
}

variable "ssh_public_key" {
  description = "Generated SSH public key"
  type        = string
}
