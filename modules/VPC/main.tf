# Internet VPC
resource "aws_vpc" "VPC" {
  cidr_block           = var.VPC_vars.vpc_cidr
  instance_tenancy     = "default"

 tags = {
    Name = "${var.local_values.RESOURCE_PREFIX}-VPC"
    }
}

# Internet GW
resource "aws_internet_gateway" "MAIN-GW" {
  vpc_id = aws_vpc.VPC.id

  tags = {
    Name = "${var.local_values.RESOURCE_PREFIX}-igw"
    }

}


# Public Route Table
resource "aws_route_table" "PUBLIC-ROUTE-TABLE" {
  vpc_id = aws_vpc.VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.MAIN-GW.id
  }
  
 tags = {
    Name = "${var.local_values.RESOURCE_PREFIX}-publicRoute"
    }
}

 data "aws_availability_zones" "available" {}

resource "aws_subnet" "PUBLIC-SUBNETS" {
count                   = length(var.VPC_vars.public_subnets)
vpc_id                  = aws_vpc.VPC.id
cidr_block              = var.VPC_vars.public_subnets[count.index]
availability_zone       = element(data.aws_availability_zones.available.names, count.index)
map_public_ip_on_launch = true 

 tags = {
    Name = "${var.local_values.RESOURCE_PREFIX}-publicSubnets"
    }

}

resource "aws_subnet" "PRIVATE-SUBNETS" {
count                   = length(var.VPC_vars.private_subnets)
vpc_id                  = aws_vpc.VPC.id
cidr_block              = var.VPC_vars.private_subnets[count.index]
availability_zone       = element(data.aws_availability_zones.available.names, count.index)
map_public_ip_on_launch = false 
 tags = {
    Name = "${var.local_values.RESOURCE_PREFIX}-privateSubnets"
    }

}

resource "aws_route_table_association" "PUBLIC-ROUTE" {
  count          = length(var.VPC_vars.public_subnets) 
  subnet_id      = element(aws_subnet.PUBLIC-SUBNETS.*.id, count.index)
  route_table_id = aws_route_table.PUBLIC-ROUTE-TABLE.id
}

resource "aws_eip" "NAT-EIP" {
  count = length(var.VPC_vars.private_subnets) > 0 ? 1 : 0
  vpc = true
  tags = {
    Name = "${var.local_values.RESOURCE_PREFIX}-nat-eip"
    }
}

resource "aws_nat_gateway" "NAT-GW" {
  count = length(var.VPC_vars.private_subnets) > 0 ? 1 : 0
  allocation_id = aws_eip.NAT-EIP[0].id
  subnet_id     = aws_subnet.PUBLIC-SUBNETS[0].id
  depends_on    = [aws_internet_gateway.MAIN-GW]
  
 tags = {
    Name = "${var.local_values.RESOURCE_PREFIX}-NAT"
    }

}

resource "aws_route_table" "PRIVATE-ROUTE-TABLE-NAT" {
  count = length(var.VPC_vars.private_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.VPC.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NAT-GW[0].id
  }

 tags = {
    Name = "${var.local_values.RESOURCE_PREFIX}-privateRoute"
    }

}

resource "aws_route_table_association" "PRIVATE-ROUTE-ASSOCIATION-NAT" {
  count = length(var.VPC_vars.private_subnets) > 0 ? length(var.VPC_vars.private_subnets) : 0
  subnet_id      = element(aws_subnet.PRIVATE-SUBNETS.*.id, count.index)
  route_table_id = aws_route_table.PRIVATE-ROUTE-TABLE-NAT[0].id
}
