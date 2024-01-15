variable "availability_zones" {  default = ["eu-west-1a", "eu-west-1b"] }
variable "vpc_cidr" { default = "10.0.0.0/16" }
variable prefix { default = "trg" }
variable "region" {  default = "eu-west-1" }
variable "suffixes" {  default = ["A", "B"] }