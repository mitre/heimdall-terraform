# Serverless InSpec (AWS)

This lambda function is meant to allow you to execute InSpec profiles in a serverless fashion. It strives to be as similar as it can be to how you would normally run `inspec exec` on your CLI, while also adding some useful functionality specific to AWS.

## Event Parameters 
```json
{
  "results_bucket":      "<The bucket to store the scan results to>",
  "profile":             "<url or alternate configuration for the source InSpec profile>",
  "ssh_key_ssm_param":   "inspec/<path to SSM secure string parameter that stores private key material>",
  "profile_common_name": "<The 'common name' of the InSpec profile that will be used in filenames>",
  "config": { // This is the direct InSpec Configuration (this example section non-exhaustive - see below)
    "target":     "<The target to run the profile against>",
    "sudo":       "<Indicates if can use sudo as the logged in user>",
    "input_file": "<location of an alternative inspec.yml configuration file for the profile>",
    "key_files":  "<A local key file to use when starting SSH session>"
  }
}
```

### Where Do The Results Go?
If you DO NOT specify the `results_bucket` parameter in the lambda event, then the results will just be logged to CloudWatch. If you DO specify the `results_bucket` parameter in the lambda event, then the lambda will attempt to save the results JSON to the S3 bucket under `unprocessed/*`. The format of the JSON is meant to be a incomplete API call to push results to a Heimdall Server and looks like this:
```json
{
  "data": {}, // this contains the HDF results
  "eval_tags": "ServerlessInspec"
}
```

### What can I put in the 'target' argument?
If you omit the `config['target']` argument, then InSpec will attempt to execute the profile against the lambda itself.

### How Do I Store and Specify an SSH Key for a Scan?
SSH keys for this lambda are expected to be stored in an Secure String parameter within Systems Manager's Parameter Store. Note that if you are trying to scan against an AWS-provided EC2 instance, then you will likely want to save the public key material to `/ec2-user/.ssh/authorized_keys` on the instance.

If you are encrypting the Secure String parameter with something other than the default KMS key (this is recommended), then you will need to ensure that the lambda's IAM role has permissions to execute `kms:Decrypt` against your KMS key.

#### SSM Managed EC2 Instance
One additional feature that this lambda provides on top of standard InSpec is that it allows you to establish an SSH session for an InSpec scan tunneled through an SSM managed instance session. This is especially useful if the lambda does not have direct network access to its target, but can have a connection through SSM. You can read more about SSM Managed Instance sessions [here](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-sessions-start.html)

You can make an EC2 instance a SSM managed instance using [this guide](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-setting-up.html). This also requires that your EC2 instance has the SSM agent software installed on it. Some AWS-provided images already have this installed, but if it is not already installed on you instance then you can use [this guide](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-setting-up.html) to get it installed. Note that tunneling through SSM for an SSH session still required that you have the credentials to authenticate to the instance.

Note that you aren't limited to just scanning AWS resources, as long as the lambda has access to the internet, then it can scan any resource that you would point a normal `inspec exec` command at.

```json
{
  ...
  "config": {
    "target": "ssh://ec2-user@i-09f17fd0396d9c6f7"
  }
}
```

```json
{
  ...
  "config": {
    "target": "ssh://ec2-user@mi-09f17fd0396d9c6f7"
  }
}
```

#### SSH
```json
{
  ...
  "config": {
    "target": "ssh://ec2-user@somednsname.aws.com"
  }
}
```

### What Kind of Profile Sources Can I Specify?
Profile sources are documented by InSpec [here](https://docs.chef.io/inspec/cli/#exec) - .

#### Zipped folder on S3 Bucket
In addition to what is already allowed by the vanilla InSpec exec command, you are able to specify a file from an AWS bucket that may be private that the lambda has permissions to access via the AWS API.

If the bucket is not public, you must provide the proper permissions to the lambda's IAM role! This also supports `tar.gz` format.
```json
{
  ...
  "profile": {
    "bucket": "inspec-profiles-bucket",
    "key": "profiles/inspec-profile.zip"
  }
}
```

#### GitHub Repository
```json
{
  ...
  "profile": "https://github.com/mitre/demo-aws-baseline.git"
}
```

#### Web hosted
```json
{
  ...
  "profile": "https://username:password@webserver/linux-baseline.tar.gz"
}
```

### Chef Supermarket
(This hasn't been tested yet!)
```json
{
  ...
  "profile": "supermarket://username/linux-baseline"
}
```

### What Kind of Input File (inspec.yml) Sources Can I Specify?
You can read more about InSpec inputs [here](https://docs.chef.io/inspec/inputs/)

#### File on S3 Bucket
```json
{
  ...
  "config": {
    "bucket": "inspec-profiles-bucket",
    "key": "input_files/custom-inspec.yml"
  }
}
```

### (Consider allowing input files to be stored in a SSM Secure String Parameter)

### Where Can I Read More about the InSpec Config?
You can read more about InSpec configuraitons [here](https://docs.chef.io/inspec/config/) and about InSpec reporters [here](https://docs.chef.io/inspec/reporters/). There are some configuration items that are always overridden so that the lambda can work properly - like the reporter, logger, and type.

InSpec doesn't necessarily document the configuration futher than this (to aid easier use of InSpec from Ruby code and not the CLI). The workaround for this was to add an interactive debugger (or even just a `puts conf` statement) to the InSpec Runner source code on a local develeopment machine (found under `/<gem source>/inspec-core-4.37.17/lib/runner.rb#initialize`). Once the interactive debugger is in place, you can specify InSpec CLI commands as you normally would and view how the configuration is affected. You can find the location of the inspec gem source by running `gem which inspec`.

## Scan Examples
These are examples of the JSON that can be passed into the lambda event to obtain a successful scan.

### AWS Resource Scanning
Note that if you are running InSpec AWS scans, then the lambda's IAM profile must have suffient permissions to analyze your environment.
```json
{
    "results_bucket": "inspec-results-bucket-dev-28wd",
    "profile": "https://github.com/mitre/aws-foundations-cis-baseline/archive/refs/heads/master.zip",
    "profile_common_name": "demo-aws-baseline-master",
    "config": {
      "target": "aws://"
    }
}
```

### RedHat 7 STIG Baseline (SSH via SSM)
```json
{
    "results_bucket": "inspec-results-bucket-dev-28wd",
    "ssh_key_ssm_param": "/inspec/test-ssh-key",
    "profile": "https://github.com/mitre/redhat-enterprise-linux-7-stig-baseline.git",
    "profile_common_name": "redhat-enterprise-linux-7-stig-baseline-master",
    "config": {
      "target": "ssh://ec2-user@i-00f1868f8f3b4eb03",
      "sudo": true
    }
}
```

### RedHat 7 STIG Baseline (SSH)
```json
{
    "results_bucket": "inspec-results-bucket-dev-28wd",
    "ssh_key_ssm_param": "/inspec/test-ssh-key",
    "profile": {
      "bucket": "inspec-profiles-bucket-dev-28wd",
      "key": "redhat-enterprise-linux-7-stig-baseline-master.zip"
    },
    "profile_common_name": "redhat-enterprise-linux-7-stig-baseline-master",
    "config": {
      "target": "ssh://ec2-user@ec2-15-200-235-74.us-gov-west-1.compute.amazonaws.com",
      "sudo": true,
      "input_file": {
        "bucket": "inspec-profiles-bucket-dev-28wd",
        "key": "rhel7-stig-baseline-master-disable-slow-controls.yml"
      }
    }
}
```

### PostgreSQL 12 STIG Baseline (TODO)
```json
"https://github.com/mitre/aws-rds-crunchy-data-postgresql-9-stig-baseline"
```

## Scheduling Recurring Scans
The recommended way to set up recurring scans is to create an Event Rule within AWS CloudWatch.

You can do this via the AWS Console using the following steps:
1. Navigate to the CloudWatch service and click `rules` on the left-hand side
2. Click the `Create Rule` button
3. Instead of `Event Pattern`, chosse the `Schedule` option and either use CRON or a standard schedule confugration
4. Click `Add a Target` with the type of `Lambda Function` and select the Serverless InSpec function
5. Expand `Configure Input` and choose `Constant (JSON text)`
6. Paste your configuration into the `Constant (JSON text)` field (this will be passed to the lambda event each time it is triggered)

