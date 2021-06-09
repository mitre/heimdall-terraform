# frozen_string_literal: true

##
# Allows running the lambda function on your local development machine for
# testing purposes.
#
# bundle exec ruby ./run_lambda_locally.rb
#
# Allowable event parameters:
#    'profile'             => <url to InSpec profile>
#    'ssh_key_ssm_param'   => <path to SSM parameter that stores private key material>,
#    'profile_common_name' => <The 'common name' of the InSpec profile that will be used in filenames>,
#    'config'              => <Direct InSpec Configuration (see below)>
#        'target'     => <The target to run the profile against>
#        'sudo'       => <Indicates if can use sudo as the logged in user>
#        'input_file' => <location of an alternative inspec.yml configuration file for the profile>
#        'key_files'  => <A local key file to use when starting SSH session>
#
# What can I put in the 'target' argument?
#    (omitting this will run the profile on the local machine)
#    ssh://ec2-user@i-09f17fd0396d9c6f7
#    ssh://ec2-user@mi-09f17fd0396d9c6f7
#    ssh://ec2-user@someawsdnsname.aws.com
#

require_relative 'lambda_function'

lambda_handler(
  event: {
    "profile" => {
      "bucket" => "inspec-profiles-bucket-dev-myzr",
      "key" => "redhat-enterprise-linux-7-stig-baseline-master.zip"
    },
    "profile_common_name" => "redhat-enterprise-linux-7-stig-baseline-master",
    "config" => {
      "target" => "ssh://ec2-user@i-00f1868f8f3b4eb03",
      "input_file" => {
        "bucket" => "inspec-profiles-bucket-dev-myzr",
        "key" => "rhel7-stig-baseline-master-disable-slow-controls.yml"
      },
      "sudo" => true
    }
  },
  context: nil
)
