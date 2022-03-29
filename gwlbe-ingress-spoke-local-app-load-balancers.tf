resource "aws_lb" "gwlbe_ingress_spoke_local_app_nlb" {
  for_each           = module.nlb_subnets
  name               = "${var.vpc_name}-${each.key}-local-test-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = [for zone in module.nlb_subnets[each.key].nlb_subnets : zone.subnet_id]

  enable_deletion_protection = false

  tags = {
    Name = "${var.vpc_name}-${each.key}-local-test-nlb"
  }
}

resource "aws_lb_target_group" "gwlbe_ingress_spoke_local_app_nlb_tg" {
  for_each = module.nlb_subnets
  name     = "${var.vpc_name}-${each.key}-local-app-nlb-tg"
  port     = 80
  protocol = "TCP"
  vpc_id   = aws_vpc.ingress.id
}



resource "aws_lb_target_group_attachment" "gwlbe_ingress_spoke_local_app_nlb_tg_attachment" {
  for_each         = merge([for app in keys(var.test_app_subnets) : {for zone in keys(var.test_app_subnets[app]) : "${app}-${zone}" => {app=app,zone=zone}}]...)
  target_group_arn = aws_lb_target_group.gwlbe_ingress_spoke_local_app_nlb_tg[each.value["app"]].arn
  target_id        = module.gwlbe_ingress_spoke_instance[each.key].instance_id
  port             = 80
}

resource "aws_lb_listener" "gwlbe_ingress_spoke_local_app_nlb_listener" {
  for_each          = aws_lb.gwlbe_ingress_spoke_local_app_nlb
  load_balancer_arn = each.value.arn
  port              = "80"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gwlbe_ingress_spoke_local_app_nlb_tg[each.key].arn
  }
}

output "gwlbe_ingress_local_app_nlb_dns_name" {
  value = [for nlb in aws_lb.gwlbe_ingress_spoke_local_app_nlb : nlb.dns_name]

}


resource "aws_security_group" "gwlbe_ingress_spoke_local_app_alb_sg" {
  for_each    = module.nlb_subnets
  name        = "${var.vpc_name}-${each.key}-local-app-alb-sg"
  description = "${var.vpc_name}-${each.key}-local-app-alb-sg"
  vpc_id      = aws_vpc.ingress.id

  ingress {
    description      = "TCP80"
    from_port        = 0
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.vpc_name}-${each.key}-local-app-alb-sg"
  }
}


resource "aws_lb" "gwlbe_ingress_spoke_local_app_alb" {
  for_each           = aws_security_group.gwlbe_ingress_spoke_local_app_alb_sg
  name               = "${var.vpc_name}-${each.key}-local-app-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [for subnet in module.nlb_subnets[each.key].nlb_subnets : subnet.subnet_id]
  security_groups    = [each.value.id]

  enable_deletion_protection = false

  tags = {
    Name = "${var.vpc_name}-${each.key}-local-app-alb"
  }
}




resource "aws_lb_target_group" "gwlbe_ingress_spoke_local_app_alb_tg" {
  for_each = module.nlb_subnets
  name     = "${var.vpc_name}-${each.key}-local-app-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.ingress.id
}



resource "aws_lb_target_group_attachment" "gwlbe_ingress_spoke_local_app_alb_tg_attachment" {
  for_each         = merge([for app in keys(var.test_app_subnets) : {for zone in keys(var.test_app_subnets[app]) : "${app}-${zone}" => {app=app,zone=zone}}]...)
  target_group_arn = aws_lb_target_group.gwlbe_ingress_spoke_local_app_alb_tg[each.value["app"]].arn
  target_id        = module.gwlbe_ingress_spoke_instance[each.key].instance_id
  port             = 80
}

resource "aws_lb_listener" "gwlbe_ingress_spoke_local_app_alb_listener" {
    for_each          = aws_lb.gwlbe_ingress_spoke_local_app_alb
    load_balancer_arn = each.value.arn
    port = "80"
    protocol = "HTTP"
    default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gwlbe_ingress_spoke_local_app_alb_tg[each.key].arn
  }
}



output "gwlbe_ingress_local_app_alb_dns_name" {
    value = [for nlb in aws_lb.gwlbe_ingress_spoke_local_app_alb : nlb.dns_name]
}
