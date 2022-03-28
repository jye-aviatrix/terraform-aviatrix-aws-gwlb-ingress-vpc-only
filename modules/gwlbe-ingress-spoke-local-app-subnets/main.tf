## Create subnet for local test app
resource "aws_subnet" "subnet" {
  for_each = var.subnet
  vpc_id               = var.vpc_id
  cidr_block           = each.value
  availability_zone_id = each.key
  tags = {
    zone_id = each.key
    Name    = "${var.vpc_name}-${var.app_name}-subnet-${each.key}"
  }
}

## Create route tables for local test app
resource "aws_route_table" "route_table" {
  for_each = var.subnet
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.gateway_id
  }

  lifecycle {
    ignore_changes = [route]
  }

  tags = {
    zone_id = each.key
    Name    = "${var.vpc_name}-${var.app_name}-subnet-${each.key}"
  }
}


## Create route table association for local test app
resource "aws_route_table_association" "gw_route_table_association" {
  for_each = aws_subnet.subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.route_table[each.key].id
}



output "subnet" {
  value = aws_subnet.subnet
}
