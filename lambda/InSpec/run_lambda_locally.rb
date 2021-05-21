# frozen_string_literal: true

##
# Allows running the lambda function on your local development machine for
# testing purposes.
#
# bundle exec ruby ./run_lambda_locally.rb
#

require_relative 'lambda_function'

lambda_handler(
  event: {
    "profile" => "https://github.com/mitre/redhat-enterprise-linux-7-stig-baseline.git",
    "ssh_key_ssm_param" => 'test-ssh-key',
    "profile_common_name" => "redhat-enterprise-linux-7-stig-baseline-master",
    "config" => {
      "target" => "ssh://ec2-user@i-09f17fd0396d9c6f7",
      "sudo" => true,
      "input_file" => ["./redhat-enterprise-linux-7-stig-baseline-master/inspec.yml"],
      "key_files" => ["/Users/jkufro/.ssh/id_rsa"]
    }
  },
  context: nil
)
