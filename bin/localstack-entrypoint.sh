#!/bin/bash
printf "Configuring localstack components..."

readonly LOCALSTACK_LAMBDA_URL=http://localhost:4566
readonly LOCALSTACK_SNS_URL=http://localhost:4566

sleep 5;

set -x

apk add jq

mkdir -p ~/.aws
echo "[default]" > ~/.aws/config 
echo "region = us-east-1" >> ~/.aws/config
echo "output = json" >> ~/.aws/config

awslocal iam create-user --user-name test
awslocal iam create-access-key --user-name test > keys.json

echo "[default]" > ~/.aws/credentials 
echo "aws_access_key_id=$(cat keys.json | jq '.AccessKey.AccessKeyId')" >> ~/.aws/credentials 
echo "aws_secret_access_key=$(cat keys.json | jq '.AccessKey.SecretAccessKey')" >> ~/.aws/credentials 

awslocal ecs create-cluster --cluster-name default

awslocal iam create-role --role-name ecsTaskExecutionRole --assume-role-policy-document '{ "Version": "2012-10-17", "Statement": [ { "Sid": "", "Effect": "Allow", "Principal": { "Service": "ecs-tasks.amazonaws.com" }, "Action": "sts:AssumeRole" } ] }'

awslocal iam attach-role-policy --role-name ecsTaskExecutionRole --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy

awslocal iam create-role --role-name ecsInstanceRole --assume-role-policy-document '{ "Version": "2012-10-17", "Statement": {
"Effect": "Allow", "Principal": {"Service": [ "ec2.amazonaws.com" ]}, "Action": "sts:AssumeRole" } }'

awslocal iam attach-role-policy --role-name ecsInstanceRole --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role

awslocal iam create-role --role-name lambda-ex --assume-role-policy-document '{"Version": "2012-10-17","Statement": [{ "Effect": "Allow", "Principal": {"Service": "lambda.amazonaws.com"}, "Action": "sts:AssumeRole"}]}'

awslocal iam attach-role-policy --role-name lambda-ex --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

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

echo 'Adding EventBridge'
awslocal events put-rule --name monitor-ecs-state-changes \
    --description "monitor lambda function for staging ecs stage changes" \
    --event-pattern "{\"source\":[\"aws.ecs\"], \"detail-type\": [\"ECS Task State Change\", \"ECS Container Instance State Change\"], \"detail\": {}}"

awslocal lambda add-permission \
    --function-name $FUNC \
    --statement-id monitoring-event \
    --action 'lambda:InvokeFunction' \
    --principal events.amazonaws.com \
    --source-arn arn:aws:events:us-east-1:000000000000:rule/monitor-ecs-state-changes

awslocal events put-targets --rule monitor-ecs-state-changes --targets "Id"="1","Arn"="arn:aws:lambda:us-east-1:000000000000:function:$FUNC"

pushd /tmp/ecs-task
    awslocal ecs register-task-definition --cli-input-json file://task-definition.json
popd

set +x

while true; do (echo -e 'HTTP/1.1 200 OK\r\n'; printf "OK") | nc -lp 8080; done
