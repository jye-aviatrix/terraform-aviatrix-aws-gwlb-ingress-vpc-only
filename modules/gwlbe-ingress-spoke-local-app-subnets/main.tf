## Create subnet for Aviatrix Spoke Gateways
resource "aws_subnet" "subnet" {
  vpc_id               = var.vpc_id
  cidr_block           = var.cidr_block
  availability_zone_id = var.zone_id
  tags = {
    zone_id = var.zone_id
    Name    = "${var.vpc_name}-test-app-subnet-${var.zone_id}"
  }
}

## Create route tables for Aviatrix Spoke Gateways
resource "aws_route_table" "route_table" {
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.gateway_id
  }

  lifecycle {
    ignore_changes = [route]
  }

  tags = {
    zone_id = var.zone_id
    Name    = "${var.vpc_name}-test-app-subnet-${var.zone_id}"
  }
}


## Create route table association for Aviatrix Spoke Gateways
resource "aws_route_table_association" "gw_route_table_association" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.route_table.id
}



output "subnet" {
  value = aws_subnet.subnet
}
