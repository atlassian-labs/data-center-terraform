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


echo "Checking the terraform state..."
# fetch the locals.tf file from terraform project
cp -fr locals.tf ./pkg/tfstate
# extract S3 bucket, dynamodb, tags, and region from locals.tf
ENVIRONMENT_NAME=$(grep 'environment_name' locals.tf | sed -nE 's/^.*"(.*)".*$/\1/p')

REGION=$(grep 'region' locals.tf | sed -nE 's/^.*"(.*)".*$/\1/p')

# Get the AWS account ID
ACCOUNTID=$(aws sts get-caller-identity --query Account --output text)

# Generate generate unique bucket and table names for the deployment of tfstate using AWS account ID
S3_BUCKET="dc-terraform-${ACCOUNTID}"
DYNAMODB_TABLE="${ENVIRONMENT_NAME}_${PRODUCT}_${ACCOUNTID}"
BUCKET_KEY="${ENVIRONMENT_NAME}-${PRODUCT}-${ACCOUNTID}"

# Generate the terraform backend, where terraform store the state of the infrastructure
sed 's/<REGION>/'${REGION}'/g'  ./pkg/templates/terraform-backend.tf.tmpl | \
sed  's/<BUCKET_NAME>/'${S3_BUCKET}'/g' | \
sed 's/<BUCKET_KEY>/'${BUCKET_KEY}'/g'  | \
sed 's/<DYNAMODB_TABLE>/'${DYNAMODB_TABLE}'/g' \
  > terraform-backend.tf

cd "$root/pkg/tfstate"

# Generate the locals for terraform state
sed 's/<REGION>/'${REGION}'/g'  ../templates/tfstate-locals.tf.tmpl | \
sed  's/<BUCKET_NAME>/'${S3_BUCKET}'/g' | \
sed 's/<BUCKET_KEY>/'${BUCKET_KEY}'/g'  | \
sed 's/<DYNAMODB_TABLE>/'${DYNAMODB_TABLE}'/g' \
  > tfstate-locals.tf

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