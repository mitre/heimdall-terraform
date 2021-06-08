# frozen_string_literal: true

##
# Allows running the lambda function on your local development machine for
# testing purposes.
#
# export HEIMDALL_URL='http://my-heimdall-server.com/evaluations'
# export HEIMDALL_API_USER=''
# export HEIMDALL_PASS_SECRET_NAME=''
# export HEIMDALL_EVAL_TAG=''
#
# bundle exec ruby ./run_lambda_locally.rb

require_relative 'lambda_function'

lambda_handler(
    event: {
        "Records" => [
            {
                "s3" => {
                    "bucket" => {
                        "name" => "inspec-results-bucket-dev-myzr"
                    },
                    "object" => {
                        "key" => "unprocessed/2021-05-27_14-14-46_ConfigToHdf.json"
                    }
                }
            }
        ]
    }, 
    context: nil
)
