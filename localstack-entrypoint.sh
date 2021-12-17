#!/bin/bash
printf "Configuring localstack components..."

readonly LOCALSTACK_LAMBDA_URL=http://localhost:4566
readonly LOCALSTACK_SNS_URL=http://localhost:4566

sleep 5;

set -x

apt install netcat jq -y

FUNC=sample-lambda
AWS_ARN_ROLE=AWSLambda_FullAccess

zip deploy.zip index.js

echo 'Creating Lambda Function'
awslocal lambda create-function --function-name $FUNC \
    --zip-file fileb://deploy.zip --handler index.handler \
    --runtime nodejs14.x --role ${AWS_ARN_ROLE}

echo 'Removing zip file';
rm deploy.zip

set +x

while true; do (echo -e 'HTTP/1.1 200 OK\r\n'; printf "OK") | nc -lp 8080; done
