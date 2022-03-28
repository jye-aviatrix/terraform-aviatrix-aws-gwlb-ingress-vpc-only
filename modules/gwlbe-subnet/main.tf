# Create GWLB endpoint subnet
resource "aws_subnet" "gwlbe_subnets" {
  for_each = var.subnet
  vpc_id            = var.vpc_id
  cidr_block        = each.value
  availability_zone_id =  each.key
  tags = {
    zone_id = each.key
    Name = "${var.vpc_name}-${var.app_name}-gwlbe-subnet-${each.key}"
  }
}


## Create route table association for GWLB endpoints
resource "aws_route_table_association" "gwlbe_route_table_association" {
  for_each = aws_subnet.gwlbe_subnets
  subnet_id      = each.value.id
  route_table_id = var.route_table_id  
}


# Create GWLB endpoints
resource "aws_vpc_endpoint" "gwlbe" {
  for_each = aws_subnet.gwlbe_subnets
  service_name      = var.gwlb_endpoint_service_name
  subnet_ids        = [each.value.id]
  vpc_endpoint_type = "GatewayLoadBalancer"
  vpc_id            = var.vpc_id
  tags = {
    zone_id = each.key
    Name = "${var.vpc_name}-${var.app_name}-gwlbe-${each.key}"
  }
}

output "gwlbe" {
  value = {
    for endpoint in aws_vpc_endpoint.gwlbe:
    endpoint.tags.zone_id => endpoint.id
  }
}