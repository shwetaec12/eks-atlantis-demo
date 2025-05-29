variable "aws_region" {
  description = "AWS region"
  default     = "eu-central-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "subnet_1_cidr" {
  description = "CIDR block for the first subnet"
  default     = "10.0.1.0/24"
}

variable "subnet_2_cidr" {
  description = "CIDR block for the second subnet"
  default     = "10.0.2.0/24"
}

variable "az_1" {
  description = "Availability zone for subnet 1"
  default     = "eu-central-1a"
}

variable "az_2" {
  description = "Availability zone for subnet 2"
  default     = "eu-central-1b"
}
