#!/bin/bash

TASK_ID=$(awslocal ecs list-tasks --cluster default | jq .taskArns[0])

if [[ ! "${#TASK_ID}" -eq 0 ]]; then
  awslocal ecs stop-task --task $TASK_ID
else
  echo "Failed to find task"
fi
