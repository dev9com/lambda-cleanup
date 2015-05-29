aws lambda create-function --region us-west-2 \
 --function-name CostWatch --zip-file fileb://lambda-node/CostWatch.zip \
 --role arn:aws:iam::722593364612:role/lambda_aws_admin_role --handler CostWatch.handler \
 --runtime nodejs --timeout 10 --memory-size 1024
