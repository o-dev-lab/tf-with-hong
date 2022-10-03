
provider "aws" {
  region  = "ap-northeast-2"
  profile = "terraform"
}


locals {
  vpc_cidr = {
        S = "10.0.0.0/16"
        M = "10.1.0.0/16"  
}


}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type = map(string)
  default = {
      S = "10.0.0.0/16"
      M = "10.1.0.0/16"  
}
  
}



variable "vpc_name" {
  description = "VPC Name"
  default     = "VPC"
}

variable "azs" {
  description = "The List of Availability Zones"
  type        = list(string)
  default     = ["ap-northeast-2a", "ap-northeast-2c"]
}



############################################################################################################
# VPC
############################################################################################################


module "vpc" {
  source   = "./module/vpc/vpc"
  for_each = var.vpc_cidr

  vpc_cidr = each.value
  vpc_name = "${var.vpc_name}-${each.key}"

}

output "vpc_id" {
  value = {for k,vpc in module.vpc : k => vpc.vpc_id}
  
}

############################################################################################################
# Public Subnet
############################################################################################################

module "pub_subnet" {
  source   = "./module/vpc/subnet"
  for_each = var.vpc_cidr

  vpc_id = module.vpc[each.key].vpc_id
  azs        = var.azs
  env        = each.key
  count_num = 2
  sub_name = "pub"
  subnetting = cidrsubnet(each.value,4,1)

}

output "pub_subnet_ids" {
  value = {for k,subnet in module.pub_subnet : k => subnet.subnet_ids}
}

############################################################################################################
# Nat GW
############################################################################################################

# module "nat" {

#   source = "../../modules/network/natgw"
#   sunbet_id = module.subnet["pub-bastion"].subnet_ids.0
# }


############################################################################################################
# Private Subnet
############################################################################################################

# variable "pri_subnet" {

  
# }

module "pri_subnet" {
  source   = "./module/vpc/subnet"
  for_each = var.vpc_cidr

  vpc_id = module.vpc[each.key].vpc_id
  azs        = var.azs
  env        = each.key
  count_num = 4
  sub_name = "pri"
  subnetting = cidrsubnet(each.value,4,2)

}

output "pri_subnet_ids" {
  value = {for k,subnet in module.pri_subnet : k => subnet.subnet_ids}
}

