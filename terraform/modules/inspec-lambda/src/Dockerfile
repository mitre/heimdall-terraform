##
# Interact with the base image:
#   docker run --rm -it --entrypoint bash public.ecr.aws/lambda/ruby:2.7
#
##
# Interact with built container:
# docker run --rm -it --entrypoint bash mitre/serverless-inspec:latest
#
#
##
# Make requests to local container: (https://docs.aws.amazon.com/lambda/latest/dg/images-test.html)
# docker run -p 9000:8080 mitre/serverless-inspec:latest
# curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{}'
#
##
#
# Build the image
#   docker build -t mitre/serverless-inspec:latest .
#     OR
#   cd terragform/modules/inspec-lambda/; ./build-image.sh

##
# Use Ruby from AWS lambda ECR
#
# https://gallery.ecr.aws/lambda/ruby
#
FROM public.ecr.aws/lambda/ruby:2.7

##
# Copy over the function code and bundle install
#
RUN yum install -y gcc make gcc-c++ git
COPY lambda_function.rb Gemfile Gemfile.lock .ruby-version /var/task/
RUN cd /var/task && git init
RUN bundle install --path vendor/bundle/

##
# Install AWS CLI
#
# https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html
#
RUN yum install -y unzip
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install
RUN rm -rf awscliv2 awscliv2.zip

##
# Install the Session Manager plugin for AWS CLI
#
# https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html
#
RUN curl \
    "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm" \
    -o "session-manager-plugin.rpm"
RUN yum install -y session-manager-plugin.rpm

##
# Set the handler
#
# https://docs.aws.amazon.com/lambda/latest/dg/images-create.html
#
CMD [ "lambda_function.lambda_handler" ]
