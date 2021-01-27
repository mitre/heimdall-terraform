# frozen_string_literal: true

##
# lambda_function.rb
#
# This lambda function is for polling AWS for Config Service Config Rule
# compliance information and coverting that to the Heimdall Data Format using
# the `heimdall_tools` gem. HDF results are pushed to a Heimdall server via
# its API. There are required environment variables to be set in order to
# properly run this lambda (these can be found below).
#
# Heimdall Enterprise Server 2.0 GitHub: https://github.com/mitre/heimdall2
#
# export HEIMDALL_URL='http://my-heimdall-server.com'
# export HEIMDALL_API_USER=''
# export HEIMDALL_PASS_SECRET_NAME=''
# export HEIMDALL_EVAL_TAG=''
# export HEIMDALL_PUBLIC='true'
#

puts "RUBY_VERSION: #{RUBY_VERSION}"

require 'aws-sdk-lambda'
require 'aws-sdk-secretsmanager'
# require 'aws-xray-sdk/lambda'
require 'heimdall_tools'
require 'json'
require 'logger'
require 'net/http'
require 'net/http/post/multipart'
require 'time'
require 'uri'

##
# The AWS lamdba entrypoint
# rubocop:disable Metrics/AbcSize, Metrics/MethodLength
def lambda_handler(event:, context:)
  logger = Logger.new($stdout)
  logger.info('## EVENT')
  logger.info(event.to_json)
  logger.info('## CONTEXT')
  logger.info(context)

  ##
  # Validate all expected ENV variables.
  # Allow event to also provide the variables.
  # If expected variables are present in the event, then they will take priority.
  logger.info('Validating environment variables...')
  %w[
    HEIMDALL_URL
    HEIMDALL_API_USER
    HEIMDALL_PASS_SECRET_NAME
    HEIMDALL_EVAL_TAG
  ].each do |var|
    ENV[var] = event[var] if !event.nil? && event.include?(var)
    err_msg = "Lambda requires the environment variable #{var} be set or to be passed via the event!"
    raise StandardError.new, err_msg if ENV[var].nil? || ENV[var].empty?
  end
  ENV['HEIMDALL_URL'] = ENV['HEIMDALL_URL'].chop if ENV['HEIMDALL_URL'].end_with?('/')
  logger.info('Validated environment variables.')

  ##
  # Get Heimdall user password from AWS SecretsManager
  # If using within a VPC and using an interface endpoint, then
  # specifying the SECRETS_MANAGER_ENDPOINT variable will allow reaching 
  # secrets manager properly.
  logger.info('Fetching Heimdall Password Secret...')
  secrets_manager_client = nil
  if ENV['SECRETS_MANAGER_ENDPOINT'].nil?
    logger.info("Using default SecretsManager endpoint.")
    secrets_manager_client = Aws::SecretsManager::Client.new
  else
    endpoint = "https://#{/vpce.+/.match(ENV['SECRETS_MANAGER_ENDPOINT'])[0]}"
    logger.info("Using SecretsManager endpoint: #{ENV['SECRETS_MANAGER_ENDPOINT']}")
    secrets_manager_client = Aws::SecretsManager::Client.new(endpoint: endpoint)
  end
  resp = secrets_manager_client.get_secret_value({ secret_id: ENV['HEIMDALL_PASS_SECRET_NAME'] })
  heimdall_user_password = resp.secret_string

  ##
  # Get a Heimdall API Token.
  #
  # https://github.com/mitre/heimdall2#api-usage
  logger.info('Getting token from Heimdall Server...')
  payload = {
    'email': ENV['HEIMDALL_API_USER'],
    'password': heimdall_user_password
  }
  resp = Net::HTTP.post(
    URI("#{ENV['HEIMDALL_URL']}/authn/login"),
    payload.to_json,
    { 'Content-Type': 'application/json' }
  )
  logger.info(resp)
  raise StandardError.new, 'Failed to get token from Heimdall Server!' unless resp.is_a?(Net::HTTPSuccess)

  logger.info('Got token from Hemdall Server.')
  token = JSON.parse(resp.body)['accessToken']
  user_id = JSON.parse(resp.body)['userID']
  raise StandardError.new, 'Returned token is not a string!' unless token.is_a?(String)
  raise StandardError.new, 'Returned user ID is not a string!' unless user_id.is_a?(String)

  ##
  # Get all AWS Config compliance as HDF.
  #
  # https://github.com/mitre/heimdall_tools
  logger.info('Running AwsConfigMapper...')
  aws_config_hdf_mapper = HeimdallTools::AwsConfigMapper.new(nil)
  hdf_hash = JSON.parse(aws_config_hdf_mapper.to_hdf)
  logger.info('AwsConfigMapper execution completed.')

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

  logger.info('Pushing HDF results to Heimdall Server...')
  url = URI("#{ENV['HEIMDALL_URL']}/evaluations")
  filename = "AWS-Config-Results-#{Time.now.utc.iso8601}"
  payload = {
    'data': UploadIO.new(StringIO.new(hdf_hash.to_json), "application/json", filename),
    'filename': filename,
    'userId': user_id,
    'public': ENV['HEIMDALL_PUBLIC'] || 'true',
    'evaluationTags': ENV['HEIMDALL_EVAL_TAG']
  }
  request = Net::HTTP::Post::Multipart.new(url.path, payload)
  request['Authorization'] = "Bearer #{token}"
  response = Net::HTTP.start(url.host, url.port) do |http|
    http.request(request)
  end

  logger.info(response)
  raise StandardError.new, 'Failed to push results to Heimdall Server!' unless response.is_a?(Net::HTTPSuccess)

  logger.info('Results pushed to Heimdall Server.')

  logger.info('Lambda completed successfully!')
end
# rubocop:enable Metrics/AbcSize, Metrics/MethodLength
