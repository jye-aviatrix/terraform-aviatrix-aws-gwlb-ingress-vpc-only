module "gwlbe_ingress_spoke_app_subnets" {
  source     = "./modules/gwlbe-ingress-spoke-local-app-subnets"
  for_each   = var.test_app_subnets
  vpc_id     = aws_vpc.ingress.id
  vpc_cidr   = var.vpc_cidr
  vpc_name   = var.vpc_name
  gateway_id = aws_internet_gateway.igw.id
  zone_id    = each.key
  cidr_block = each.value
}

module "gwlbe_ingress_spoke_instance" {
  source    = "./modules/aws-linux-vm-public"
  for_each   = var.test_app_subnets
  vm_name   = "gwlbe-ingress-spoke-instance-${each.key}"
  vpc_id    = aws_vpc.ingress.id
  subnet_id = module.gwlbe_ingress_spoke_app_subnets[each.key].subnet.id
  key_name  = var.key_pair_name
}


