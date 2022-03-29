variable "key_pair_name" {
  description = "Provide EC2 key pair name"
  default     = "ec2-key-pair"
}
variable "region" {
  default = "us-west-1"
}

variable "vpc_name" {
  default     = "GWLBe"
  description = "Provide VPC name"
}

variable "vpc_cidr" {
  default     = "10.100.0.0/24"
  description = "Provide VPC CIDR range, smallest subnet in AWS is /28. We need at least 2x /28 for Aviatrix Spoke Gateway, 2x /28 for GWLB endpoint, 2x /28 for public NLB, so the minium size should be /25"
}


variable "gwlb_endpoint_service_name" {
  default = "com.amazonaws.vpce.us-west-1.vpce-svc-02e8866f03e63eaf6"
}


variable "gwlbe_subnets" {
  default = {
    "app1" = {
      "usw1-az1" = "10.100.0.0/28"
      "usw1-az3" = "10.100.0.16/28"
    }
    "app2" = {
      "usw1-az1" = "10.100.0.64/28"
      "usw1-az3" = "10.100.0.80/28"
    }
  }
}

variable "lb_subnets" {
  default = {
    "app1" = {
      "usw1-az1" = "10.100.0.32/28"
      "usw1-az3" = "10.100.0.48/28"
    }
    "app2" = {
      "usw1-az1" = "10.100.0.96/28"
      "usw1-az3" = "10.100.0.112/28"
    }
  }
}

# Reserved for Aviatrix Spoke Gateways
variable "gw_subnets" {
  default = {
    "usw1-az1" = "10.100.0.224/28"
    "usw1-az3" = "10.100.0.240/28"
  }
}


variable "test_app_subnets" {
  default = {
    "app1" = {
      "usw1-az1" = "10.100.0.160/28"
      "usw1-az3" = "10.100.0.176/28"
    }
    "app2" = {
      "usw1-az1" = "10.100.0.192/28"
      "usw1-az3" = "10.100.0.208/28"
    }
  }
}
