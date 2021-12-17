#!/bin/bash
printf "Configuring localstack components..."

readonly LOCALSTACK_LAMBDA_URL=http://localhost:4566
readonly LOCALSTACK_SNS_URL=http://localhost:4566

sleep 5;

set -x

apt install netcat jq -y -q

FUNC=sample-lambda
AWS_ARN_ROLE=AWSLambda_FullAccess

pushd /tmp/lambda 
    zip -r deploy.zip ./*

    echo 'Creating Lambda Function'
    awslocal lambda create-function --function-name $FUNC \
        --zip-file fileb://deploy.zip --handler index.handler \
        --runtime nodejs14.x --role ${AWS_ARN_ROLE} \
        --environment "Variables={DOCKER_GATEWAY_HOST=$DOCKER_GATEWAY_HOST,API_PORT=$API_PORT}"

    echo 'Removing zip file';
    rm deploy.zip
popd

set +x

while true; do (echo -e 'HTTP/1.1 200 OK\r\n'; printf "OK") | nc -lp 8080; done
