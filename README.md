# Cloud CI\CD using AWS!

[Build Statuse](https://github.com/runalsh/epam_again_aws/actions/workflows/aws.yaml/badge.svg)

Simple Python app to get data from https://www.metaweather.com/api with storing to AWS RDS/

Cloud - Amazon Web Service (and Google Cloud in another repo but its not completed)

Backend, frontend apps - Python , Flask, REST API

IAC - Terraform

Orchestration - Kubernetes

Logging -  AWS CloudWatch

Monitoring -  AWS CloudWatch Dashboard

Runtime/Deployment - Ci/Cd Github Action

Scalability/redundancy - Kubernetes HPA

Tests - Pylint, Sonarcube, Pytest, Bandit

Alert - AWS SNS 


Before start you must declare some SECRETS to GA Store:

__Core__

AWS_ACCESS_KEY - AWS access key

AWS_DEFAULT_REGION - you region

AWS_SECRET_KEY - AWS secret key

SONAR_TOKEN - get from https://sonarcloud.io

__Information about progress - Telegram__

start dialog with @BotFather and create new bot. After take token below "Use this token to access the HTTP API:" its seems like "653654654:GJBkjnfuikbjkbkbgrkjgbkgbnsjkfneladk" and it will be TELEGRAM_TOKEN secret.

Now start dialog with new bot and open in browser page https://api.telegram.org/bot<<you_token>>/getUpdates,  find chat_id seem like 56275476 and its y TELEGRAM_TO secret!

TELEGRAM_TO

TELEGRAM_TOKEN

You will be informed about FAILs in workflow



# TASK

Variant7. 
Using API https://www.metaweather.com/api/ get data about weather in Moscow
for current month and store it into your DB: id, weather_state_name,
wind_direction_compass, created, applicable_date, min_temp, max_temp, the_temp.
Output the data by date (the date is set) in form of a table and sort them by
created in ascending order. 





