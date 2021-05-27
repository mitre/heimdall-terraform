VERSION=$(cat '../../../lambda/InSpec/.version')

docker build -t mitre/serverless-inspec:$VERSION ../../../lambda/InSpec
docker tag mitre/serverless-inspec:$VERSION mitre/serverless-inspec:latestd

docker save mitre/serverless-inspec:$VERSION > serverless-inspec.tar

