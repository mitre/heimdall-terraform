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

### NOTICE

© 2022 The MITRE Corporation.

Approved for Public Release; Distribution Unlimited. Case Number 18-3678.

### NOTICE

MITRE hereby grants express written permission to use, reproduce, distribute, modify, and otherwise leverage this software to the extent permitted by the licensed terms provided in the LICENSE.md file included with this project.

### NOTICE

This software was produced for the U. S. Government under Contract Number HHSM-500-2012-00008I, and is subject to Federal Acquisition Regulation Clause 52.227-14, Rights in Data-General.

No other use other than that granted to the U. S. Government, or to those acting on behalf of the U. S. Government under that Clause is authorized without the express written permission of The MITRE Corporation.

For further information, please contact The MITRE Corporation, Contracts Management Office, 7515 Colshire Drive, McLean, VA 22102-7539, (703) 983-6000.
