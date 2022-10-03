#############################################################################################
### provider
#############################################################################################

# provider "aws" {
#   region  = "ap-northeast-2"
#   profile = "terraform"
# }

#############################################################################################
### variable
#############################################################################################

variable "env" {}
variable "sub_name" {}
variable "count_num" {
  type = number
}
variable "azs" {
  description = "The List of Availability Zones"
  type        = list(string)
  default     = ["ap-northeast-2a", "ap-northeast-2c"]
}
variable "subnetting" {
  description = "The CIDR block List of the Subnets"
  type        = string
}
variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

# variable "igw_id" {
#   description = "The ID of the IGW"
#   type        = string
# }

# variable "nat_id" {
#   description = "The ID of the NATGW"
#   type        = string
# }

#############################################################################################
### resource
#############################################################################################


resource "aws_subnet" "subnet" {
  count = var.count_num
  vpc_id = var.vpc_id
  cidr_block = cidrsubnet(var.subnetting, var.count_num, count.index)
  availability_zone = var.azs[(count.index+1)%length(var.azs)]
  tags = {
    Name = "${var.env}-${var.sub_name}-sub-${substr(var.azs[(count.index+1)%length(var.azs)], -1, -1)}"
  }

}




# resource "aws_route_table" "rt" {
#   vpc_id = var.vpc_id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = substr(var.env,0,3) == "pub" ? var.igw_id : null
#     nat_gateway_id = substr(var.env,0,3) == "pri" ? var.nat_id : null
#   }

#   tags = {
#     Name = "${var.env}-rt"
#   }
# }

# resource "aws_route_table_association" "rt_asso" {
#   count = length(var.subnetting)
#   subnet_id      = aws_subnet.subnet[count.index].id
#   route_table_id = aws_route_table.rt.id
# }


#############################################################################################
### output
#############################################################################################



output "subnet_ids" {
  value = aws_subnet.subnet.*.id
}

# output "rt_id" {
#   value = aws_route_table.rt.*.id
# }