#===== variables =================

variable "region" {
  type    = string
}

variable "public_subnets" {
  default = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "key_name" {
  type    = string
}

variable "key_name2" {
  type    = string
}

variable "clustername" {
  type    = string
}

variable "db_name" {
  type    = string
}

variable "dbuser" {
  type    = string
}

variable "dbpasswd" {
  type    = string
}

variable "instance_type" {
  type    = string
}

variable "db_instance_type" {
  type    = string
}

variable "db_instance_name" {
  type    = string
}

variable "clusternode_type" {
  type    = string
}

variable "minnumberofnodes" {
  type    = string
}

variable "maxnumberofnodes" {
  type    = string
}

variable "desirednumberofnodes" {
  type    = string
}

variable "domain" {
  type    = string
}

variable "alarms_email" {
  type    = string
}

# variable "telegramtoken" {
#   type      = string
#   sensitive = true
# }


