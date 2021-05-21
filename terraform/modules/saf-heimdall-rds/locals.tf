locals {
  name = "saf${var.env}"

  tags = {
    "terraform" = "true",
    "env"       = var.env,
    "project"   = "saf-rds"
  }
}