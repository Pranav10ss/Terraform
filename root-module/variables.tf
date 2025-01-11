variable "tags" {
    description = "Remote backend for terraform to store its state files in an S3 bucket"
    type = map(string)
    default = {}
}

variable "region" {}

variable "vpc_cidr" {}

variable "pub_sub_1a_cidr" {}

variable "pub_sub_2b_cidr" {}

variable "pri_sub_3a_cidr" {}

variable "pri_sub_4b_cidr" {}

variable "pri_sub_5a_cidr" {}

variable "pri_sub_6b_cidr" {}

variable "db_username" {}

variable "db_password" {}

variable "certificate_domain_name" {}

variable "additional_domain_name" {}