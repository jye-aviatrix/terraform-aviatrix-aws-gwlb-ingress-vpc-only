# Create NLB subnet
resource "aws_subnet" "nlb_subnets" {
  for_each = var.subnet
  vpc_id            = var.vpc_id
  cidr_block        = each.value
  availability_zone_id =  each.key
  tags = {
    zone_id = each.key
    Name = "${var.vpc_name}-${var.app_name}-nlb-subnet-${each.key}"
  }
}

## Create route tables for NLB subnets
resource "aws_route_table" "nlb_route_tables" {
  for_each = var.subnet
  vpc_id            = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    vpc_endpoint_id = var.gwlbe[each.key]
  }

  lifecycle {
    ignore_changes = [route]
  }

  tags = {
    zone_id = each.key
    Name = "${var.vpc_name}-${var.app_name}-nlb-subnet-${each.key}"
  }
}

## Create route table association for NLB subnets
resource "aws_route_table_association" "nlb_route_table_association" {
  for_each = aws_route_table.nlb_route_tables
  subnet_id      = aws_subnet.nlb_subnets[each.value.tags.zone_id].id
  route_table_id = each.value.id 
}

output "nlb_subnets" {
  value = {
    for nlb_subnet in aws_subnet.nlb_subnets:
    nlb_subnet.tags.zone_id => {
      cidr_block = nlb_subnet.cidr_block
      subnet_id = nlb_subnet.id
    }
  }
}

