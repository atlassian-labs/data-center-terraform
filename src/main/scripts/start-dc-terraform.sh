#!/usr/bin/env bash

set -x
root="$(pwd)"

# fetch the locals.tf file from terraform project
cp -fr locals.tf ./src/main/tfstate

# extract S3 bucket, dynamodb, and region from locals.tf
S3_BUCKET=$(grep 'bucket_name' locals.tf | sed -nE 's/^.*"(.*)".*$/\1/p')
DYNAMODB_TABLE=$(grep 'dynamodb_name' locals.tf | sed -nE 's/^.*"(.*)".*$/\1/p')
REGION=$(grep 'region' locals.tf | sed -nE 's/^.*"(.*)".*$/\1/p')

# Generate the terraform backend, where terraform store the state of the infrastructure
sed 's/<REGION>/'${REGION}'/g'  ./src/main/templates/terraform-backend.tmpl | \
  sed  's/<BUCKET_NAME>/'${S3_BUCKET}'/g' | \
  sed 's/<DYNAMODB_TABLE>/'${DYNAMODB_TABLE}'/g' \
  > terraform-backend.tf

cd "$root/src/main/tfstate"

# Check if the S3 bucket is existed otherwise create the bucket to keep the terraform state
aws s3api head-bucket --bucket "$S3_BUCKET"
if [ $? -eq 0 ]
then
  echo "S3 bucket '$S3_BUCKET' is already existed."
  cd "$root"
else
  # create s3 bucket to be used for keep state of the terraform project
  terraform init
  terraform apply -auto-approve
  sleep 5s

  cd "ß"
  terraform init -migrate-state
fi


terraform init
terraform apply -auto-approve