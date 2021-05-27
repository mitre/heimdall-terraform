
require 'aws-sdk-lambda'
require 'aws-sdk-ssm'
require 'aws-sdk-s3'
require 'json'
require 'inspec'
require 'logger'
# require 'byebug'
# require 'aws-sdk'

puts "RUBY_VERSION: #{RUBY_VERSION}"
$logger = Logger.new($stdout)

##
#
# https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html#install-plugin-macos
#   curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/mac/sessionmanager-bundle.zip" -o "sessionmanager-bundle.zip"
#   unzip sessionmanager-bundle.zip
#   sudo ./sessionmanager-bundle/install -i /usr/local/sessionmanagerplugin -b /usr/local/bin/session-manager-plugin
#   rm -rf ./sessionmanager-bundle 
#   rm -f sessionmanager-bundle.zip
#
# https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-getting-started-enable-ssh-connections.html
#
# `~/.ssh/config`
#   host i-* mi-*
#       ProxyCommand sh -c "aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'"
#   ssh -i ~/.ssh/id_rsa ec2-user@i-09f17fd0396d9c6f7
#   ssh -i ~/.ssh/id_rsa -o ProxyCommand="sh -c \"aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'\"" ec2-user@i-09f17fd0396d9c6f7
#
# https://docs.chef.io/inspec/config/
#
# InSpec Exec allows several ways of specifying the profile that you want to execute.
#   - Local folder
#   - GitHub SSH & HTTPS
#   - Web hosted ZIP file
#   - (https://docs.chef.io/inspec/cli/#exec)
#
def lambda_handler(event:, context:)
  # Set export filename
  filename, file_path = generate_json_file(event['profile_common_name'] || 'unnamed_profile')
  json_reporter = "json:" + file_path
  $logger.info("Will write JSON at #{file_path}")

  # Build the config we will use when executing InSpec
  config = build_config(event, file_path)

  # Define InSpec Runner
  $logger.info('Building InSpec runner.')
  runner = Inspec::Runner.new(config)

  # Set InSpec Target
  $logger.info('Adding InSpec target.')
  runner.add_target(event["profile"], config)

  # Trigger InSpec Scan
  $logger.info('Running InSpec.')
  runner.run

  s3_client = Aws::S3::Client.new
  s3_client.put_object({
    body: StringIO.new({
      "data" => JSON.parse(File.read(file_path)),
      "eval_tags" => "ServerlessInspec"
    }.to_json), 
    bucket: event['results_bucket'], 
    key: "unprocessed/#{filename}", 
  }) unless event['results_bucket'].nil?
end

##
# Generates the configuration that will be used for the InSpec execution
#
def build_config(event, file_path)
  # Download S3 files if needed
  handle_s3_profile(event)
  handle_s3_input_file(event)

  # Start with a default config and merge in the config that was passed into the lambda
  config = default_config.merge(event['config'] || {}).merge(forced_config(file_path))

  # Add private key to config if it is present
  ssh_key = fetch_ssh_key(event['ssh_key_ssm_param'])
  config["key_files"] = [ssh_key] unless ssh_key.nil?

  if /ssh:\/\/.+@m?i-[a-z0-9]{17}/.match? config['target'] 
    $logger.info('Using proxy SSM session to SSH to managed EC2 instance.')
    # debugging puts, remove later
    puts `sh -c "aws ssm start-session --target i-09f17fd0396d9c6f7 --document-name AWS-StartSSHSession --parameters portNumber=22"`
    config["proxy_command"] = 'sh -c "aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters portNumber=%p"'
  end

  $logger.info("Built config: #{config}")
  config
end

##
# If "profile" is a zip from an S3 bucket (notated by "profile" being a hash)
# then we need to fetch the file and download it to /tmp/
#
# https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/S3/Client.html
#
def handle_s3_profile(event)
  return unless event["profile"].is_a? Hash

  unless event.dig("profile", "key").end_with? '.zip'
    $logger.error 'InSpec profiles from S3 are only supported as ZIP files!'
    exit 1
  end

  profile_download_path = '/tmp/inspec-profile.zip'
  $logger.info("Downloading InSpec profile to #{profile_download_path}")
  s3 = Aws::S3::Client.new
  s3.get_object({ bucket: event["profile"]["bucket"], key: event["profile"]["key"] }, target: profile_download_path)

  event["profile"] = profile_download_path
end

##
# If "input_file" is located in an S3 bucket (notated by "profile" being a hash)
# then we need to fetch the file and download it to /tmp/
#
# https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/S3/Client.html
#
def handle_s3_input_file(event)
  return unless event.dig("config", "input_file").is_a? Hash

  input_file_download_path = '/tmp/inspec-input_file.yml'
  $logger.info("Downloading InSpec input_file to #{input_file_download_path}")
  s3 = Aws::S3::Client.new
  s3.get_object(
    { bucket: event["config"]["input_file"]["bucket"], key: event["config"]["input_file"]["key"] },
    target: input_file_download_path
  )

  event["config"]["input_file"] = [input_file_download_path]
end

##
# Fetch the SSH key from SSM Parameter Store if the function execution requires it
#
# If ENV['SSM_ENDPOINT'] is set, then it will use that VPC endpoint to reach SSM.
#
# Params:
# - ssh_key_ssm_param:String The SSM Parameter identifier to fetch
#
# Returns:
# - nil if no key has been fetched, or path to key if downloaded.
def fetch_ssh_key(ssh_key_ssm_param)
  if ssh_key_ssm_param.nil? || ssh_key_ssm_param.empty?
    $logger.info('ssh_key_ssm_param is blank. Will not fetch SSH key.')
    return nil
  end

  ssm_client = nil
  if ENV['SSM_ENDPOINT'].nil?
    $logger.info("Using default SSM Parameter Store endpoint.")
    ssm_client = Aws::SSM::Client.new
  else
    endpoint = "https://#{/vpce.+/.match(ENV['SSM_ENDPOINT'])[0]}"
    $logger.info("Using SSM Parameter Store endpoint: #{endpoint}")
    ssm_client = Aws::SSM::Client.new(endpoint: endpoint)
  end
  resp = ssm_client.get_parameter({
    name: ssh_key_ssm_param,
    with_decryption: true,
  })
  file_path = '/tmp/id_rsa'
  File.write(file_path, resp.parameter.value)
  file_path
end

##
# This is the configuration that is absolutely necessary
# for the lambda to function properly
#
def forced_config(file_path)
  {
    "logger" => Logger.new(nil),
    "type" => :exec, 
    "reporter" => {
      "cli" => {
        "stdout" => true
      },
      "json" => {
        "file" => file_path,
        "stdout" => false
      }
    }
  }
end

##
# This is the configuration that is NOT absolutely necessary
# and can be overridden by configuration passed to the lambda
#
def default_config
  {
    "version" => "1.1",
    "cli_options" => {
      "color" => "true"
    },
    "show_progress" => false, 
    "color" => true, 
    "create_lockfile" => true, 
    "backend_cache" => true, 
    "enable_telemetry" => false, 
    "winrm_transport" => "negotiate", 
    "insecure" => false, 
    "winrm_shell_type" => "powershell", 
    "distinct_exit" => true, 
    "diff" => true, 
    "sort_results_by" => "file", 
    "filter_empty_profiles" => false, 
    "reporter_include_source" => false, 
    
  }
end


def generate_json_file(name)
  filename = "#{Time.now.strftime("%Y-%m-%d_%H-%M-%S")}_#{name}.json"
  file_path = '/tmp/' + filename
  return filename, file_path
end
