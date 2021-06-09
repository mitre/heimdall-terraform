# NNC AWS SAF

This repository is meant to implement [SAF](https://saf.mitre.org/#/) within AWS.

## Harden
- Utilizes [terragrunt](https://terragrunt.gruntwork.io/) & [terraform](https://www.terraform.io/) for our IaC

## Validate
- Utilizes a serverless implementation of InSpec that is capable of running arbitrary InSpec profiles against AWS resources, EC2 instances, off-cloud resources, and more. Specific scans can be sceduled to run regularly to provide up-to-date inspections of the environmnet.

## Normalize
- Utilizes a serverless implementation of the AWS Config [heimdall_tools](https://github.com/mitre/heimdall_tools) data mapper 

## Visualize
- Utilizes Heimdall Server to collect and store HDF results from any valid source.
- Utilizes a serverless function which processes & pushes HDF results up to Heimdall Server as soon as they reach a watched S3 Bucket.
