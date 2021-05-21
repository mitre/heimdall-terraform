locals {
  public_subnet_cidrs = [
    cidrsubnet(var.vpc_cidr, ceil(log(6, 2)), 0),
    cidrsubnet(var.vpc_cidr, ceil(log(6, 2)), 1),
  ]

  private_subnet_cidrs = [
    cidrsubnet(var.vpc_cidr, ceil(log(6, 2)), 2),
    cidrsubnet(var.vpc_cidr, ceil(log(6, 2)), 3),
  ]

  name = "saf-tenant-${var.env}"

  tags = {
    "terraform" = "true",
    "env"       = var.env,
    "project"   = "saf-tenant"
  }
}