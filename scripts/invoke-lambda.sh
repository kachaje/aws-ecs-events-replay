#!/bin/bash

awslocal lambda invoke \
    --cli-binary-format raw-in-base64-out \
    --function-name sample-lambda \
    --payload '{ "name": "Bob" }' \
    response.json
