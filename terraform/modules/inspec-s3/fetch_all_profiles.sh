
set -e

git clone https://github.com/mitre/redhat-enterprise-linux-7-stig-baseline.git || (cd redhat-enterprise-linux-7-stig-baseline && git pull)