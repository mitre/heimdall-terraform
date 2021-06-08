# frozen_string_literal: true

##
# lambda_function.rb
#
# This lambda function is for polling AWS for Config Service Config Rule
# compliance information and coverting that to the Heimdall Data Format using
# the `heimdall_tools` gem.
#
# Once HDF results are acquired, then the function will invoke the
# HeimdallPusher lambda function for it to process the results.
#
# The name of the HeimdallPusher lambda function can be passed via the event or
# via an ENV variable (event will take priority).
#   - ENV['heimdall_pusher_lambda'] = 'name-of-lambda'
#   - event = { "heimdall_pusher_lambda": "name-of-lambda" }
#

require 'aws-sdk-lambda'
require 'aws-sdk-s3'
require 'heimdall_tools'
require 'json'
require 'logger'

puts "RUBY_VERSION: #{RUBY_VERSION}"
$logger = Logger.new($stdout)

##
# The AWS lamdba entrypoint
#
def lambda_handler(event:, context:)
  $logger.info('## EVENT')
  $logger.info(event.to_json)
  $logger.info('## CONTEXT')
  $logger.info(context)

  ##
  # Get all AWS Config compliance as HDF.
  #
  # https://github.com/mitre/heimdall_tools
  $logger.info('Running AwsConfigMapper...')
  aws_config_hdf_mapper = nil
  if ENV['CONFIG_MANAGER_ENDPOINT'].nil?
    $logger.info("Using default Config endpoint.")
    aws_config_hdf_mapper = HeimdallTools::AwsConfigMapper.new(nil)
  else
    endpoint = "https://#{/vpce.+/.match(ENV['CONFIG_MANAGER_ENDPOINT'])[0]}"
    $logger.info("Using Config endpoint: #{endpoint}")
    aws_config_hdf_mapper = HeimdallTools::AwsConfigMapper.new(nil, endpoint)
  end
  hdf_hash = JSON.parse(aws_config_hdf_mapper.to_hdf)
  $logger.info('AwsConfigMapper execution completed.')

  ##
  # Save results into S3 to be processed later
  #
  results_bucket = event.nil? ? nil : event['results_bucket']
  results_bucket ||= ENV['results_bucket']
  filename = "#{Time.now.strftime("%Y-%m-%d_%H-%M-%S")}_ConfigToHdf.json"
  # Consider tagging with the account ID
  $logger.info('Pushing results to S3')
  s3_client = Aws::S3::Client.new
  s3_client.put_object({
    body: StringIO.new({
      "data" => hdf_hash,
      "eval_tags" => "ConfigToHdf"
    }.to_json), 
    bucket: results_bucket, 
    key: "unprocessed/#{filename}", 
  }) unless results_bucket.nil?

  $logger.info('Lambda completed successfully!')
end
