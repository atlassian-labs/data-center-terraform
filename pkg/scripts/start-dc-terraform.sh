#!/usr/bin/env bash

set -e
root="$(pwd)"

if [[ ! -f  "./config.auto.tfvars" ]]; then
  echo "Configuration file 'config.auto.tfvar' is not defined yet."
  echo "Please run the following command and then add proper value to 'config.auto.tfvar' using a text editor."
  echo "Then re-run the script to deploy the infrastructure."
  echo
  echo "cp config.auto.tfvar.example config.auto.tfvar"
  exit 0
fi


echo "Checking the terraform state..."
# fetch the config.tfvar file from terraform project
cp -fr locals.tf ./pkg/tfstate
# extract S3 bucket, dynamodb, and region from config.tfvar
S3_BUCKET=$(grep 'bucket_name' locals.tf | sed -nE 's/^.*"(.*)".*$/\1/p')
DYNAMODB_TABLE=$(grep 'dynamodb_name' locals.tf | sed -nE 's/^.*"(.*)".*$/\1/p')
REGION=$(grep 'region' locals.tf | sed -nE 's/^.*"(.*)".*$/\1/p')

# Generate the terraform backend, where terraform store the state of the infrastructure
sed 's/<REGION>/'${REGION}'/g'  ./pkg/templates/terraform-backend.tmpl | \
  sed  's/<BUCKET_NAME>/'${S3_BUCKET}'/g' | \
  sed 's/<DYNAMODB_TABLE>/'${DYNAMODB_TABLE}'/g' \
  > terraform-backend.tf

cd "$root/pkg/tfstate"

# Check if the S3 bucket is existed otherwise create the bucket to keep the terraform state

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