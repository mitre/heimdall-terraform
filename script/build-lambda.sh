# https://docs.aws.amazon.com/lambda/latest/dg/python-package.html
# https://docs.aws.amazon.com/lambda/latest/dg/ruby-package.html

FUNCTION_NAME='InSpec'

cd lambda/$FUNCTION_NAME

bundle config set path --local 'vendor/bundle'
bundle install

rm -f function.zip

zip -r function.zip .
