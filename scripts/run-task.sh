#!/bin/bash

awslocal ecs run-task --cluster default --task-definition fargate-task-definition:1
