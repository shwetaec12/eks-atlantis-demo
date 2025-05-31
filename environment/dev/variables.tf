variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_1_cidr" {
  description = "List of public subnet CIDR blocks"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_2_cidr" {
  description = "List of public subnet CIDR blocks"
  type        = string
  default     = "10.0.2.0/24"
}

variable "availability_zone1" {
  description = "List of availability zones"
  type        = string
  default     = "eu-central-1a"
}

variable "availability_zone2" {
  description = "List of availability zones"
  type        = string
  default     = "eu-central-1b"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}
