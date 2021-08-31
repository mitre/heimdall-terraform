##
# starting from RHEL 7.9 base image
#
# ssh ec2-user@ec2-52-222-16-132.us-gov-west-1.compute.amazonaws.com
#
# aws ssm start-session --target i-029d376edcbfc0f20
#  > bash
#  > sudo su - ec2-user

set -x

##
# Start in home directory
#
cd

##
# ENV variable check
#
if [ -z "$GIT_AUTH" ]; then
    echo '$GIT_AUTH is a required ENV variable!'
    echo "export GIT_AUTH='<uid>:<token>'"
    exit 1
fi

if [ -z "$REGION" ]; then
    echo '$REGION is a required ENV variable!'
    echo "export REGION='<Current AWS Region>'"
    echo 'us-gov-west-1, us-west-1, etc.'
    exit 1
fi

##
# Install SSM Agent
#
sudo yum install -y "https://s3.$REGION.amazonaws.com/amazon-ssm-$REGION/latest/linux_amd64/amazon-ssm-agent.rpm"
sudo systemctl start amazon-ssm-agent
sudo systemctl enable amazon-ssm-agent
sudo systemctl status amazon-ssm-agent

##
# Install YUM dependencies
#
# /etc/yum.repos.d/centos-extras.repo
REPO='/etc/yum.repos.d/centos-extras-test.repo'
if [ ! -f "$REPO" ]; then
    sudo touch $REPO
    sudo echo -e '[centos-extras]
    name=Centos extras - $basearch
    baseurl=http://mirror.centos.org/centos/7/extras/x86_64
    enabled=1
    gpgcheck=0
    ' | sudo tee $REPO > /dev/null
fi
sudo yum install -y git zip bzip2 gcc make unzip openssl-devel openssl gcc-c++

##
# Install rbenv
# https://github.com/rbenv/rbenv
# https://github.com/rbenv/ruby-build
#
if ! command -v rbenv &> /dev/null
then
    git clone https://github.com/rbenv/rbenv.git ~/.rbenv
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
    ~/.rbenv/bin/rbenv init
    echo 'eval "$(rbenv init - bash)"' >> ~/.bash_profile
    mkdir -p "$(rbenv root)"/plugins
    git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
    rbenv install 2.7.2
    rbenv global 2.7.2
fi

##
# Install InSpec
#
gem install inspec -v 4.38.9
gem install inspec-bin -v 4.38.9
gem install train-kubernetes -v 0.1.6
inspec plugin install train-kubernetes
inspec plugin install train-aws

##
# Install Docker
# https://docs.docker.com/engine/install/centos/
#
if ! command -v docker &> /dev/null
then
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    sudo yum install -y docker-ce docker-ce-cli containerd.io
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo docker run --rm hello-world
    # sudo chmod 666 /var/run/docker.sock
    sudo usermod -aG docker ec2-user
fi

##
# Install AWS CLI and plugins
#
# Install the AWS CLI
if ! command -v aws &> /dev/null
then
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    rm -rf awscliv2 awscliv2.zip aws
    # Install the session-manager-plugin for the AWS CLI
    curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm" \
        -o "session-manager-plugin.rpm"
    sudo yum install -y session-manager-plugin.rpm
    rm -rf session-manager-plugin.rpm
fi

##
# Install terraform & terragrunt
# https://learn.hashicorp.com/tutorials/terraform/install-cli
# https://terragrunt.gruntwork.io/docs/getting-started/install/
#
if ! command -v terraform &> /dev/null
then
    sudo yum install -y yum-utils
    sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
    sudo yum -y install terraform
    sudo echo -e 'plugin_cache_dir   = "$HOME/.terraform.d/plugin-cache"
disable_checkpoint = true' >> ~/.terraformrc
    terraform -help
fi
if ! command -v terragrunt &> /dev/null
then
    sudo curl -L 'https://github.com/gruntwork-io/terragrunt/releases/download/v0.30.7/terragrunt_linux_amd64' \
        -o /usr/local/bin/terragrunt
    sudo chmod +x /usr/local/bin/terragrunt
fi

##
# Fetch Docker images and back them up to tar files
#
mkdir ~/docker-images/
docker pull ghcr.io/mitre/serverless-heimdall-pusher-lambda:0.1.1
docker save ghcr.io/mitre/serverless-heimdall-pusher-lambda:0.1.1 > ~/docker-images/serverless-heimdall-pusher-lambda-0.1.1.tar

docker pull ghcr.io/mitre/serverless-inspec-lambda:0.15.5
docker save ghcr.io/mitre/serverless-inspec-lambda:0.15.5 > ~/docker-images/serverless-inspec-lambda-0.15.5.tar

docker pull mitre/heimdall2:release-latest
docker save mitre/heimdall2:release-latest > ~/docker-images/heimdall2.tar

##
# Copy heimdall2.tar to proper location
#
cp ~/docker-images/heimdall2.tar ~/awsconfigs/terraform/modules/saf-heimdall-ecr/heimdall2.tar

##
# AWS Credentials
#
mkdir ~/.aws/
touch ~/.aws/config
touch ~/.aws/credentials

##
# Get code
#
git clone "https://$GIT_AUTH@code.il2.dso.mil/dod-cloud-iac/awsconfigs.git"

##
# Package up ConfigToHdf
#
(cd awsconfigs && ./script/build-lambda.sh)

##
# Get external module git dependencies in case they are not cached as expected 
#
mkdir ~/additional-repos/
cd ~/additional-repos/
git clone https://github.com/mitre/serverless-heimdall-pusher-lambda.git
git clone https://github.com/mitre/serverless-inspec-lambda.git
cd

##
# Fetch and archive InSpec profiles
#
mkdir ~/inspec-profiles/
cd ~/inspec-profiles/
# must git init for `git remote show` commands to succeed
git init
git clone https://gitlab.dsolab.io/scv-content/inspec/kubernetes/baselines/k8s-cluster-stig-baseline.git
inspec archive --tar k8s-cluster-stig-baseline
git clone https://gitlab.dsolab.io/scv-content/inspec/kubernetes/baselines/k8s-node-stig-baseline.git
inspec archive --tar k8s-node-stig-baseline
git clone https://github.com/mitre/redhat-enterprise-linux-7-stig-baseline
inspec archive --tar redhat-enterprise-linux-7-stig-baseline
git clone https://github.com/mitre/redhat-enterprise-linux-8-stig-baseline
inspec archive --tar redhat-enterprise-linux-8-stig-baseline
git clone https://github.com/mitre/microsoft-windows-server-2016-stig-baseline
inspec archive --tar microsoft-windows-server-2016-stig-baseline
git clone https://github.com/mitre/microsoft-windows-server-2019-stig-baseline
inspec archive --tar microsoft-windows-server-2019-stig-baseline
git clone https://github.com/mitre/microsoft-windows-10-stig-baseline
inspec archive --tar microsoft-windows-10-stig-baseline
git clone https://github.com/mitre/aws-foundations-cis-baseline
inspec archive --tar aws-foundations-cis-baseline
git clone https://github.com/mitre/aws-rds-oracle-mysql-ee-5.7-cis-baseline
inspec archive --tar aws-rds-oracle-mysql-ee-5.7-cis-baseline
git clone https://github.com/mitre/aws-rds-infrastructure-cis-baseline
inspec archive --tar aws-rds-infrastructure-cis-baseline
git clone https://github.com/mitre/kubernetes-cis-baseline
inspec archive --tar kubernetes-cis-baseline
cd

##
# Copy the upload helper script to ~/inspec-profiles/
#
cp ~/awsconfigs/script/push-profiles-to-s3.sh ~/inspec-profiles/push-profiles-to-s3.sh
chmod +x ~/inspec-profiles/push-profiles-to-s3.sh

##
# Fetch AWS CLI packages that may be needed elsewhere
#
# https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html
#
mkdir ~/aws-cli/
cd ~/aws-cli/
# Windows
curl -L 'https://awscli.amazonaws.com/AWSCLIV2.msi' -o 'AWSCLIV2.msi'
    # Just run the installer on Windows.
# Linux x86
curl -L 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o 'awscli-exe-linux-x86_64.zip'
    # unzip awscliv2.zip
    # sudo ./aws/install
# Linux ARM
curl -L 'https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip' -o 'awscli-exe-linux-aarch64.zip'
    # unzip awscliv2.zip
    # sudo ./aws/install
# Mac OS
curl -L 'https://awscli.amazonaws.com/AWSCLIV2.pkg' -o 'AWSCLIV2.pkg'
    # Just run the installer.
cd

##
# Fetch AWS CLI Session Manager plugin packages that may be needed elsewhere
#
# https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html
#
mkdir ~/aws-cli/session-manager
cd ~/aws-cli/session-manager
# Windows
curl -L 'https://s3.amazonaws.com/session-manager-downloads/plugin/latest/windows/SessionManagerPluginSetup.exe' -o 'SessionManagerPluginSetup.exe'
    # Just run the installer on Windows.
# Linux x86_64
curl -L 'https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm' -o 'x86_64-session-manager-plugin.rpm'
    # sudo yum install -y session-manager-plugin.rpm
# Linux x86
curl -L 'https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_32bit/session-manager-plugin.rpm' -o 'x86-session-manager-plugin.rpm'
    # sudo yum install -y session-manager-plugin.rpm
# Linux arm64
curl -L 'https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_arm64/session-manager-plugin.rpm' -o 'arm64-session-manager-plugin.rpm'
    # sudo yum install -y session-manager-plugin.rpm
# Mac OS
curl -L 'https://s3.amazonaws.com/session-manager-downloads/plugin/latest/mac/session-manager-plugin.pkg' -o 'session-manager-plugin.pkg'
    # sudo installer -pkg session-manager-plugin.pkg -target /
    # ln -s /usr/local/sessionmanagerplugin/bin/session-manager-plugin /usr/local/bin/session-manager-plugin 
cd

##
# Clean up
#
yum clean all
sudo rm -rf /var/cache/yum/