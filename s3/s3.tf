#==== prov ======================

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.region
}

#===== variables =================

variable "region" {
  default = "eu-central-1"
}



#========== S3 ==============

resource "aws_s3_bucket" "terraform_state" {
   bucket = "statebucket-myy"
   lifecycle {
     prevent_destroy = true
   }
    versioning {
      enabled = true
    }
 } 
 