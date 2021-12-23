#!/bin/bash

pushd ../

  docker pull localstack/localstack:latest

  SERVICES="lambda,sns,sts,iam,s3,cloudwatchlogs,events,ecs,ecr,cloudformation,events,ec2,logs" docker-compose up --build 

popd
