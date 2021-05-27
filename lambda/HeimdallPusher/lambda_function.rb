# frozen_string_literal: true

##
# lambda_function.rb
#
# This lambda function is for ...
#
# Heimdall Enterprise Server 2.0 GitHub: https://github.com/mitre/heimdall2
#
# export HEIMDALL_URL='http://my-heimdall-server.com'
# export HEIMDALL_API_USER=''
# export HEIMDALL_PASS_SSM_PARAM=''
# export HEIMDALL_EVAL_TAG=''
# export HEIMDALL_PUBLIC='true'
#

require 'aws-sdk-lambda'
require 'aws-sdk-ssm'
require 'aws-sdk-s3'
require 'json'
require 'logger'
require 'net/http'
require 'net/http/post/multipart'
require 'time'
require 'uri'

puts "RUBY_VERSION: #{RUBY_VERSION}"
$logger = Logger.new($stdout)

##
# The AWS lamdba entrypoint
#
# Invoking lambda from the Ruby SDK:
# https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/Lambda/Client.html#invoke_async-instance_method
#
def lambda_handler(event:, context:)
  puts event

  # validate_variables(event)

  records = (event['Records'] || [])
  records.each do |record|
      bucket_name = record.dig('s3', 'bucket', 'name')
      object_key = record.dig('s3', 'object', 'key')
      process_record(event, bucket_name, object_key)
  end

  $logger.info('Lambda completed successfully!')
end

##
# Process a S3 record that was passed via the event
#
def process_record(event, bucket_name, object_key)
  return if bucket_name.nil? || object_key.nil?

  record_contents = get_record_contents(bucket_name, object_key)
  hdf = record_contents['data']
  filename = object_key.split('/').last

  record_contents['eval_tags'] = record_contents['eval_tags'].nil? ? 'HeimdallPusher' : record_contents['eval_tags'] + ',HeimdallPusher'

  # Save to Heimdall
  heimdall_user_password = get_heimdall_password
  user_id, token = get_heimdall_api_token(heimdall_user_password)
  push_to_heimdall(hdf, user_id, token, record_contents['eval_tags'])

  # Save to S3
  save_results_to_bucket(record_contents, bucket_name, filename)
  save_hdf_to_bucket(hdf, bucket_name, filename)
  remove_unprocessed_from_bucket(bucket_name, object_key)
end

def get_record_contents(bucket_name, object_key)
  $logger.info('Fetching HDF record.')
  s3_client = Aws::S3::Client.new
  JSON.parse(s3_client.get_object(bucket: bucket_name, key: object_key).body.read)
end

def save_hdf_to_bucket(hdf, bucket_name, filename)
  $logger.info('Saving processed HDF to bucket.')
  s3_client = Aws::S3::Client.new
  s3_client.put_object({
    body: StringIO.new(hdf.to_json), 
    bucket: bucket_name, 
    key: "hdf/#{filename}", 
  }) 
end

def save_results_to_bucket(results, bucket_name, filename)
  $logger.info('Saving processed result to bucket.')
  s3_client = Aws::S3::Client.new
  s3_client.put_object({
    body: StringIO.new(results.to_json), 
    bucket: bucket_name, 
    key: "processed/#{filename}", 
  }) 
end

def remove_unprocessed_from_bucket(bucket_name, object_key)
  $logger.info('Removing unprocessed result from bucket.')
  s3_client = Aws::S3::Client.new
  s3_client.delete_object({
    bucket: bucket_name, 
    key: object_key, 
  })
end

##
# Validate all expected variables.
#
# Allow event to also provide the variables - data must be passed in the event.
#
# If expected variables are present in the event, then they will take priority.
#
def validate_variables(event)
  $logger.info('Validating environment variables...')
  %w[
    HEIMDALL_URL
    HEIMDALL_API_USER
    HEIMDALL_PASS_SSM_PARAM
    HEIMDALL_EVAL_TAG
  ].each do |var|
    ENV[var] = event[var] if !event.nil? && event.include?(var)
    err_msg = "Lambda requires the environment variable #{var} be set or to be passed via the event!"
    raise StandardError.new, err_msg if ENV[var].nil? || ENV[var].empty?
  end
  ENV['HEIMDALL_URL'] = ENV['HEIMDALL_URL'].chop if ENV['HEIMDALL_URL'].end_with?('/')
  $logger.info('Validated environment variables.')
end

##
# Get Heimdall user password from AWS SSM Parameter Store.
#
# If using within a VPC and using an interface endpoint, then
# specifying the SSM_ENDPOINT variable will allow reaching
# SSM parameter store properly.
#
def get_heimdall_password
  $logger.info('Fetching Heimdall Password Secret from SSM parameter store...')
  ssm_client = nil

  if ENV['SSM_ENDPOINT'].nil?
    $logger.info('Using default SSM Parameter Store endpoint.')
    ssm_client = Aws::SSM::Client.new
  else
    endpoint = "https://#{/vpce.+/.match(ENV['SSM_ENDPOINT'])[0]}"
    $logger.info("Using SSM Parameter Store endpoint: #{endpoint}")
    ssm_client = Aws::SSM::Client.new(endpoint: endpoint)
  end

  resp = ssm_client.get_parameter({
                                    name: ENV['HEIMDALL_PASS_SSM_PARAM'],
                                    with_decryption: true
                                  })

  resp.parameter.value
end

##
# Get a Heimdall API Token.
#
# https://github.com/mitre/heimdall2#api-usage
#
def get_heimdall_api_token(heimdall_user_password)
  $logger.info('Getting token from Heimdall Server...')
  payload = {
    'email': ENV['HEIMDALL_API_USER'],
    'password': heimdall_user_password
  }
  resp = Net::HTTP.post(
    URI("#{ENV['HEIMDALL_URL']}/authn/login"),
    payload.to_json,
    { 'Content-Type': 'application/json' }
  )
  $logger.info(resp)
  raise StandardError.new, 'Failed to get token from Heimdall Server!' unless resp.is_a?(Net::HTTPSuccess)

  $logger.info('Got token from Hemdall Server.')
  token = JSON.parse(resp.body)['accessToken']
  user_id = JSON.parse(resp.body)['userID']

  raise StandardError.new, 'Returned token is not a string!' unless token.is_a?(String)
  raise StandardError.new, 'Returned user ID is not a string!' unless user_id.is_a?(String)

  [user_id, token]
end

##
# Post HDF to Heimdall Server.
# - evaluationTags is expected to be a comma separated list of tag names.
#
# https://github.com/mitre/heimdall2#api-usage
# https://www.rubydoc.info/stdlib/net/Net%2FHTTPHeader:set_form
# https://github.com/socketry/multipart-post
#
# curl -v -F "data=@aws_config_hdf.json" \
#   -F "filename=AWS-Config-Results-2021-03-12T15:24:47Z" \
#   -F "public=true" \
#   -F "evaluationTags=my-tag,my-other-tag" \
#   -H "Authorization: Bearer <token>" \
#   "http://my-heimdall/evaluations"
#
def push_to_heimdall(hdf, user_id, token, eval_tags)
  $logger.info('Pushing HDF results to Heimdall Server...')
  url = URI("#{ENV['HEIMDALL_URL']}/evaluations")
  filename = "AWS-Config-Results-#{Time.now.utc.iso8601}"
  payload = {
    'data': UploadIO.new(StringIO.new(hdf.to_json), 'application/json', filename),
    'filename': filename,
    'userId': user_id,
    'public': ENV['HEIMDALL_PUBLIC'] || 'true',
    'evaluationTags': eval_tags
  }
  request = Net::HTTP::Post::Multipart.new(url.path, payload)
  request['Authorization'] = "Bearer #{token}"
  response = Net::HTTP.start(url.host, url.port) do |http|
    http.request(request)
  end

  $logger.info(response)
  raise StandardError.new, 'Failed to push results to Heimdall Server!' unless response.is_a?(Net::HTTPSuccess)

  $logger.info('Results pushed to Heimdall Server.')
end
