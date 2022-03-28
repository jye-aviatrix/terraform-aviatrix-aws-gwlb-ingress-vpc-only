module "gwlbe_ingress_spoke_app_subnets" {
  source     = "./modules/gwlbe-ingress-spoke-local-app-subnets"
  for_each   = var.test_app_subnets
  vpc_id     = aws_vpc.ingress.id
  vpc_cidr   = var.vpc_cidr
  vpc_name   = var.vpc_name
  gateway_id = aws_internet_gateway.igw.id
  app_name   = each.key
  subnet     = each.value
}

module "gwlbe_ingress_spoke_instance" {
  source    = "./modules/aws-linux-vm-public"
  for_each   = merge([for app in keys(var.test_app_subnets) : {for zone in keys(var.test_app_subnets[app]): "${app}-${zone}" => {app=app,zone=zone}}]...)
  vm_name   = "${var.vpc_name}-${each.key}"
  vpc_id    = aws_vpc.ingress.id
  subnet_id = module.gwlbe_ingress_spoke_app_subnets[each.value["app"]].subnet[each.value["zone"]].id
  key_name  = var.key_pair_name
  tags = {
      app = each.value["app"]
      zone = each.value["zone"]
  }
}


