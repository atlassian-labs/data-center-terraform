# This script will generate/override the `./pkg/tfstate/tfstate-locals.tf` and `./terraform-backend.tf`

SCRIPT_PATH=$(dirname "$0")
if [ ! $# -eq 2 ]; then
      echo "The filename for terraform backend and tfstate local variable are missing."
      echo
      echo "Syntax: generate-tfstate-backend.sh <path_to_root/backend-terraform.tf> <path_to_tfstate/tfstate-local.tf>"
      exit 1
fi

BACKEND_TF="${1}"
TFSTATE_LOCALS="${2}"

CONFIG_FILE="${SCRIPT_PATH}/../../config.auto.tfvars"


# extract S3 bucket, dynamodb, tags, and region from locals.tf
ENVIRONMENT_NAME=$(grep 'environment_name' ${CONFIG_FILE} | sed -nE 's/^.*"(.*)".*$/\1/p')
REGION=$(grep 'region' ${CONFIG_FILE} | sed -nE 's/^.*"(.*)".*$/\1/p')

# Get the AWS account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Generates the unique s3 bucket and key names for the deployment for keeping the terraform state
S3_BUCKET="atlassian-dc-${REGION}-${AWS_ACCOUNT_ID}-tf-state"
BUCKET_KEY="${ENVIRONMENT_NAME}-${AWS_ACCOUNT_ID}"

# length of the bucket name should be less than 64 characters
S3_BUCKET="${S3_BUCKET:0:63}"

# Generates the unique dynamodb table names for the deployment lock ( convert all '-' to '_' )
DYNAMODB_TABLE="tloc_${ENVIRONMENT_NAME//-/_}_${AWS_ACCOUNT_ID}"


# Generate the terraform backend, where terraform store the state of the infrastructure
echo "Generating the terraform backend definition file 'terraform.backend.tf'."
sed 's/<REGION>/'${REGION}'/g'  "${SCRIPT_PATH}/../templates/terraform-backend.tf.tmpl" | \
sed  's/<BUCKET_NAME>/'${S3_BUCKET}'/g' | \
sed 's/<BUCKET_KEY>/'${BUCKET_KEY}'/g'  | \
sed 's/<DYNAMODB_TABLE>/'${DYNAMODB_TABLE}'/g' \
  > ${BACKEND_TF}

# Generate the locals for terraform state
echo "Generating the terraform state local file 'pkg/tfstate/tfstate-locals.tf'."
sed 's/<REGION>/'${REGION}'/g'  ./pkg/templates/tfstate-locals.tf.tmpl | \
sed  's/<BUCKET_NAME>/'${S3_BUCKET}'/g' | \
sed 's/<BUCKET_KEY>/'${BUCKET_KEY}'/g'  | \
sed 's/<DYNAMODB_TABLE>/'${DYNAMODB_TABLE}'/g' \
  > ${TFSTATE_LOCALS}
