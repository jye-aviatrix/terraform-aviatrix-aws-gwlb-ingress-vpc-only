


# Create a VPC
resource "aws_vpc" "ingress" {
  cidr_block = var.vpc_cidr
  tags = {
    "Name" = "${var.vpc_name}-vpc"
  }
}

# Create internet gateway and associate with VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.ingress.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

# Retrive avaiability zones
data "aws_availability_zones" "available" {}

module "avx_spoke_gw_subnets" {
  source = "./modules/avx-spoke-gw-subnet"
  for_each = var.gw_subnets
  vpc_id = aws_vpc.ingress.id
  vpc_cidr = var.vpc_cidr
  vpc_name = var.vpc_name
  gateway_id = aws_internet_gateway.igw.id
  cidr_block = each.value
  zone_id = each.key
}

# Create GWLB endpoint route table, only need one for entire VPC as they all point 0/0 to IGW
resource "aws_route_table" "gwlbe_route_table" {
  vpc_id            = aws_vpc.ingress.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  lifecycle {
    ignore_changes = [route]
  }
  tags = {
    Name = "${var.vpc_name}-gwlbe-subnets"
  }
}

# Create GWLB endpoint subnet, route table, route table association and GWLB endpoints
module "gwlbe" {
  source = "./modules/gwlbe-subnet"
  for_each = var.gwlbe_subnets
  vpc_id = aws_vpc.ingress.id
  vpc_cidr = var.vpc_cidr
  vpc_name = var.vpc_name
  route_table_id = aws_route_table.gwlbe_route_table.id
  gwlb_endpoint_service_name = var.gwlb_endpoint_service_name
  app_name = each.key
  subnet = each.value
}


# Create NLB subnet, route table, route table association
module "nlb_subnets" {
  source = "./modules/nlb-subnet"
  for_each = var.lb_subnets
  vpc_id = aws_vpc.ingress.id
  vpc_cidr = var.vpc_cidr
  vpc_name = var.vpc_name
  gwlbe = module.gwlbe[each.key].gwlbe
  app_name = each.key
  subnet = each.value
}


# Create route tables for IGW edge, associate NLB subnet CIDR with GWLB endpoint in corresponding AZ
resource "aws_route_table" "igw_route_table" {
  vpc_id            = aws_vpc.ingress.id
  dynamic "route" {
    for_each = merge([for app in keys(var.gwlbe_subnets) : {for zone_id in keys(var.gwlbe_subnets[app]) : module.nlb_subnets[app].nlb_subnets[zone_id].cidr_block => module.gwlbe[app].gwlbe[zone_id]}]...)
    content {
      cidr_block = route.key
      vpc_endpoint_id = route.value
    }
  }

  tags = {
    Name = "${var.vpc_name}-igw-edge-route-table"
  }
  depends_on = [
    module.nlb_subnets,
    module.gwlbe
  ]
}


# Associate IGW edge route to IGW
resource "aws_route_table_association" "igw_edge_association" {
  gateway_id      = aws_internet_gateway.igw.id
  route_table_id = aws_route_table.igw_route_table.id
}

