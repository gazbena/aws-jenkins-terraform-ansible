terraform {
  required_providers {
    ansible = {
      version = "~> 1.1.0"
      source  = "ansible/ansible"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  # backend "s3" {
  #   region  = "us-east-1"
  #   profile = "default"
  #   key     = "terraformstatefile"
  #   bucket  = "terraform-state-bucket-4039"
  # }
}

# Defining multiple providers using "alias" parameter
provider "aws" {
  profile = "default"
  region  = "us-east-1"
  alias   = "region_master"
}

provider "aws" {
  profile = "default"
  region  = "us-west-2"
  alias   = "region_worker"
}
