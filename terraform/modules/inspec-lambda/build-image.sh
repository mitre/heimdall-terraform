
docker build -t mitre/serverless-inspec:latest ../../../lambda/InSpec

docker save mitre/serverless-inspec:latest > serverless-inspec.tar

