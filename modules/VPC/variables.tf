variable "tags" {
    type = map(string)
    description = "A map of tags to assign to resources"
    default = {}
}

variable "vpc_cidr" {
    description = "CIDR block for the VPC"
    type = string
}

variable "region" {}

variable "pub_sub_1a_cidr" {}

variable "pub_sub_2b_cidr" {}

variable "pri_sub_3a_cidr" {}

variable "pri_sub_4b_cidr" {}

variable "pri_sub_5a_cidr" {}

variable "pri_sub_6b_cidr" {}
