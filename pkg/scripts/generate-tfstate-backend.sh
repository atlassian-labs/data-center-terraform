
root="$(pwd)"

if [[ $1 == "-skip" ]]; then
  BACKEND_TF=terraform-backend.tf
  TFSTATE_LOCALS=pkg/tfstate/tfstate-locals.tf
  if [[ -f $BACKEND_TF && -f $TFSTATE_LOCALS ]]; then
    echo "Skipped generating tfstate variable files. The existing files will be used."
    exit 0
  fi
    echo "Terraform state variable files does not existed."
    exit 1
fi

echo "Generating the terraform state variables."
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

# Generate the locals for terraform state
sed 's/<REGION>/'${REGION}'/g'  ./pkg/templates/tfstate-locals.tf.tmpl | \
sed  's/<BUCKET_NAME>/'${S3_BUCKET}'/g' | \
sed 's/<BUCKET_KEY>/'${BUCKET_KEY}'/g'  | \
sed 's/<DYNAMODB_TABLE>/'${DYNAMODB_TABLE}'/g' \
  > ./pkg/tfstate/tfstate-locals.tf
