module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.1"
  cidr    = var.vpc_cidr
  azs     = data.aws_availability_zones.current_zones.names

  public_subnets = [
    for num in range(length(data.aws_availability_zones.current_zones.names)) :
    cidrsubnet(var.vpc_cidr, 8, num + length(data.aws_availability_zones.current_zones.names) + 1)
    ///  //10.0.3.0/24,10.0.4.0/24,10.0.5.0/24
  ]

  private_subnets = [
    for num in range(length(data.aws_availability_zones.current_zones.names)) :
    cidrsubnet(var.vpc_cidr, 8, num)
    ///   // 10.0.0.0/24, 10.0.1.0/24,10.0.2.0/24
  ]
  public_subnet_tags = {
    Tier = "public"
  }
  private_subnet_tags = {
    Tier = "private"
  }

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway = true
  single_nat_gateway = true

}