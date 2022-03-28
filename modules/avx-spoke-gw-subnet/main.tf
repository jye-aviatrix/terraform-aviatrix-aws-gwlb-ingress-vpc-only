## Create subnets for Aviatrix Spoke Gateways
resource "aws_subnet" "gw_subnet" {
  vpc_id               = var.vpc_id
  cidr_block           = var.cidr_block
  availability_zone_id = var.zone_id
  tags = {
    zone_id = var.zone_id
    Name    = "${var.vpc_name}-gateway-subnet-${var.zone_id}"
  }
}

## Create route tables for Aviatrix Spoke Gateways
resource "aws_route_table" "gw_route_table" {
  vpc_id            = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.gateway_id
  }

  lifecycle {
    ignore_changes = [route]
  }

  tags = {
    zone_id = var.zone_id
    Name = "${var.vpc_name}-gateway-subnet-${var.zone_id}"
  }
}

## Create route table association for Aviatrix Spoke Gateways
resource "aws_route_table_association" "gw_route_table_association" {
  subnet_id      = aws_subnet.gw_subnet.id
  route_table_id = aws_route_table.gw_route_table.id
}

output "gw_subnet_cidr_block" {
  value = aws_subnet.gw_subnet.cidr_block
}
