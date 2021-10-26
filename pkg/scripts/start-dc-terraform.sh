#!/usr/bin/env bash

set -e
root="$(pwd)"

if [ $# -eq 0 ]
  then
    PRODUCT="bamboo"
else
  # for now only bamboo is supported
  declare -l PRODUCT
  PRODUCT=$1
  if [ $PRODUCT != "bamboo" ]; then
    echo "'$1' is not supported."
    exit 1
  fi
fi

# This script will generate the `./pkg/tfstate/tfstate-locals.tf` and `./terraform-backend.tf`
# to skip this part you can pass `-skip` as the second parameter when you run this script
source "./pkg/scripts/generate-tfstate-backend.sh" ${2}
# fetch the locals.tf file from terraform project
cp -fr locals.tf ./pkg/tfstate
cd "$root/pkg/tfstate"

# Check if the S3 bucket is existed otherwise create the bucket to keep the terraform state
echo "Checking the terraform state."
set +e
aws s3api head-bucket --bucket "$S3_BUCKET"
S3_BUCKET_EXISTS=$?
set -e
if [ $S3_BUCKET_EXISTS -eq 0 ]
then
  echo "S3 bucket '$S3_BUCKET' is already existed."
  cd "$root"
else
  # create s3 bucket to be used for keep state of the terraform project
  echo "Creating '$S3_BUCKET' bucket for storing the terraform state..."
  terraform init
  terraform apply -auto-approve
  sleep 5s

  echo "Migrating the terraform state to S3 bucket..."
  cd "$root"
  terraform init -migrate-state
fi

Echo "Starting to analyze the infrastructure..."
terraform init
terraform apply -auto-approve