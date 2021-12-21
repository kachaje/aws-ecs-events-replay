# aws-ecs-events-lambda-sample
Sample app to demonstrate integration of `AWS` services `ECS`, `EventBridge` and `Lambda Functions` for testing in `Localstack`.

## Tools
Tools are in `/scripts` directory and are as follows:

### 1. `start.sh`
For starting the `docker-compose` setup of the applications

### 2. `stop.sh`
For stopping the applications started in `1`

### 3. `invoke-lambda.sh`
For invoking the `Lambda Function` independent of the full workflow

### 4. `trigger-eventbridge.sh`
For triggering the `EventBridge` event call independent of the full workflow which then calls the `Lambda Function`

### 5. `run-task.sh`
For starting the `ECS Task` which is then supposed to run the normal flow 
