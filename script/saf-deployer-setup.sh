##
# starting from RHEL 7.9 base image
#
# ssh ec2-user@ec2-52-222-16-132.us-gov-west-1.compute.amazonaws.com
#
# aws ssm start-session --target i-029d376edcbfc0f20
#  > bash
#  > sudo su - ec2-user

##
# Install SSM Agent
#
REGION='us-gov-west-1'
sudo yum install -y "https://s3.$REGION.amazonaws.com/amazon-ssm-$REGION/latest/linux_amd64/amazon-ssm-agent.rpm"
sudo systemctl start amazon-ssm-agent
sudo systemctl enable amazon-ssm-agent
sudo systemctl status amazon-ssm-agent

##
# Install YUM dependencies
#
# /etc/yum.repos.d/centos-extras.repo
REPO='/etc/yum.repos.d/centos-extras-test.repo'
sudo touch $REPO
sudo echo -e '[centos-extras]
name=Centos extras - $basearch
baseurl=http://mirror.centos.org/centos/7/extras/x86_64
enabled=1
gpgcheck=0
' | sudo tee $REPO > /dev/null
sudo yum install -y git bzip2 gcc make unzip openssl-devel openssl

##
# Install rbenv
# https://github.com/rbenv/rbenv
# https://github.com/rbenv/ruby-build
#
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
~/.rbenv/bin/rbenv init
echo 'eval "$(rbenv init - bash)"' >> ~/.bash_profile
mkdir -p "$(rbenv root)"/plugins
git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
rbenv install 2.7.2
rbenv global 2.7.2

##
# Install Docker
# https://docs.docker.com/engine/install/centos/
#
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y docker-ce docker-ce-cli containerd.io
sudo systemctl start docker
sudo systemctl enable docker
sudo docker run hello-world
sudo chmod 666 /var/run/docker.sock

##
# Install AWS CLI and plugins
#
# Install the AWS CLI 
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf awscliv2 awscliv2.zip aws
# Install the session-manager-plugin for the AWS CLI
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm" \
    -o "session-manager-plugin.rpm"
sudo yum install -y session-manager-plugin.rpm
rm -rf session-manager-plugin.rpm

##
# Install terraform & terragrunt
# https://learn.hashicorp.com/tutorials/terraform/install-cli
# https://terragrunt.gruntwork.io/docs/getting-started/install/
#
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum -y install terraform
terraform -help
sudo curl -L 'https://github.com/gruntwork-io/terragrunt/releases/download/v0.30.7/terragrunt_linux_amd64' \
    -o /usr/local/bin/terragrunt
sudo chmod +x /usr/local/bin/terragrunt
sudo echo -e 'plugin_cache_dir   = "$HOME/.terraform.d/plugin-cache"
disable_checkpoint = true' >> ~/.terraformrc

##
# Fetch Docker images
#
docker pull ghcr.io/mitre/serverless-heimdall-pusher-lambda:0.1
docker pull ghcr.io/mitre/serverless-inspec-lambda:0.12

##
# AWS Credentials
#
mkdir ~/.aws/
touch ~/.aws/config
touch ~/.aws/credentials

##
# Get code
#
GIT_AUTH='<uid>:<token>'
git clone "https://$GIT_AUTH@code.il2.dso.mil/dod-cloud-iac/awsconfigs.git"

##
# Clean up
#
yum clean all
sudo rm -rf /var/cache/yum/