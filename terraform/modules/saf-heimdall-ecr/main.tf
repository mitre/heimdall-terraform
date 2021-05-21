
##
# The configuration for this backend will be filled in by Terragrunt
#
# https://terragrunt.gruntwork.io/docs/features/keep-your-remote-state-configuration-dry/
#
terraform {
  backend "s3" {}
}

##
# Elastic Container Registry for SAF deployment
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository
#
resource "aws_ecr_repository" "mitre_heimdall2" {
  name                 = "mitre/heimdall2"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "null_resource" "push_image" {
  depends_on = [
    aws_ecr_repository.mitre_heimdall2,
  ]

  # Ensures this script always runs
  triggers = {
    always_run = timestamp()
  }

  # https://www.terraform.io/docs/language/resources/provisioners/local-exec.html
  provisioner "local-exec" {
    command = "./push-image.sh"

    environment = {
      AWS_REGION     = var.aws_region
      AWS_ACCOUNT_ID = var.account_id
      IMAGE_FILE     = "heimdall2.tar"
      REPO_NAME      = "mitre/heimdall2"
      IMAGE_TAG      = "release-latest"
    }
  }
}