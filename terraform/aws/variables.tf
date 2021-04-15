
#############################################################
# Variables Configuration
#############################################################
variable "aws_access_key" {
  default = "***REMOVED***"
}

variable "aws_secret_key" {
  default = "***REMOVED***"
}

variable "cluster-name" {
  default = "imply-cluster"
  type    = string
}

variable "node_count" {
  default = 4
}

variable "aws_region" {
  default = "eu-west-2"
}

variable "az_count" {
  default = "2"
}

variable "owner" {
  default = "richard.dobson@imply.io"
}

variable "dbpw" {
  default = "Qwerty123!"
}


variable "cprovider" {
  default = "aws"
  description = "Terraform for AWS Cloud"
}
variable "db_identifier" {
  default     = "imply"
  description = "Identifier for your DB"
}

variable "db_storage" {
  default     = "10"
  description = "Storage size in GB"
}

variable "db_engine" {
  default     = "mysql"
  description = "Engine type, example values mysql, postgres"
}

variable "engine_version" {
  description = "Engine version"

  default = {
    mysql    = "5.7.21"
    postgres = "9.6.8"
  }
}

variable "db_instance_class" {
  default     = "db.t2.micro"
  description = "Instance class"
}

variable "db_name" {
  default     = "imply"
  description = "db name"
}

variable "db_username" {
  default     = "imply"
  description = "User name"
}

variable "db_password" {
  description = "password, provide through your ENV variables"
  default     = "Qwerty123!"
}

variable "bucket_name" {
  description = "bucket_name"
  default     = "rdo-imply-terraform"
}

variable "master_count" {
  default     = 3
}
variable "query_count" {
  default     = 2
}
variable "data_count" {
  default     = 2
}

variable "instance_type" {
  default     = "m4.large"
}
variable "master_instance_type" {
  default     = "m4.large"
}
variable "query_instance_type" {
  default     = "m5.2xlarge"
}
variable "data_instance_type" {
  default     = "i3.8xlarge"
}
