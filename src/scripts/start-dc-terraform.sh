#!/usr/bin/env bash

set -x
cwd=$(pwd)

# fetch the locals.tf file from terraform project
cp -fr locals.tf ./src/tfstate
cd ./src/initialization
pwd
# extract S3 bucket name from locals.tf
S3_BUCKET=$(grep 'bucket_name' locals.tf | sed -nE 's/^.*"(.*)".*$/\1/p')

# Check if the S3 bucket is existed otherwise create the bucket to keep the terraform state
aws s3api head-bucket --bucket "$S3_BUCKET"
if [ $? -eq 0 ]
then
  echo "S3 bucket '$S3_BUCKET' is already existed."
else
  # create s3 bucket to be used for keep state of the terraform project
  terraform init
  terraform apply -auto-approve

  cd "$pwd"
  terraform init -migrate-state
fi


terraform init
terraform apply -auto-approve