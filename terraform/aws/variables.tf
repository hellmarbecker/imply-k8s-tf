#
# Variables Configuration
#
variable "aws_access_key" {
  default = "put in our own key"
  sensitive = true
}

variable "aws_secret_key" {
  default = "put in your own secret"
  sensitive = true
}

variable "cluster-name" {
  default = "imply-cluster"
  type    = "string"
}

variable "node_count" {
  default = 15
}

variable "aws_region" {
  default = "eu-central-1"
}

variable "az_count" {
  default = "3"
}


variable "cprovider" {
  default = "aws"
  description = "Terraform for AWS Cloud"
}
