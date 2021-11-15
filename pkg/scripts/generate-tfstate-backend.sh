# This script will generate/override the `./pkg/tfstate/tfstate-locals.tf` and `./terraform-backend.tf`

SCRIPT_PATH=$(dirname "$0")
if [ ! $# -eq 3 ]; then
      echo "The filename for terraform backend and tfstate local variable are missing."
      echo
      echo "Usage: generate-tfstate-backend.sh <config_file> <path_to_root/backend-terraform.tf> <path_to_tfstate/tfstate-local.tf>"
      exit 1
fi

CONFIG_FILE="${1}"
BACKEND_TF="${2}"
TFSTATE_LOCALS="${3}"


# extract S3 bucket, dynamodb, tags, and region from locals.tf
ENVIRONMENT_NAME=$(grep 'environment_name' ${CONFIG_FILE} | sed -nE 's/^.*"(.*)".*$/\1/p')
REGION=$(grep 'region' ${CONFIG_FILE} | sed -nE 's/^.*"(.*)".*$/\1/p')

# Get the AWS account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Generates the unique s3 bucket and key names for the deployment for keeping the terraform state
S3_BUCKET="atlas-${ENVIRONMENT_NAME}-${REGION}-${AWS_ACCOUNT_ID}-tfstate"
BUCKET_KEY="${ENVIRONMENT_NAME}-${AWS_ACCOUNT_ID}"

# length of the bucket name should be less than 64 characters
S3_BUCKET="${S3_BUCKET:0:63}"

# Generates the unique dynamodb table names for the deployment lock ( convert all '-' to '_' )
DYNAMODB_TABLE="tf_lock_${ENVIRONMENT_NAME//-/_}_${AWS_ACCOUNT_ID}"


# Generate the terraform backend, where terraform store the state of the infrastructure
echo "Generating the terraform backend definition file 'terraform.backend.tf'."
sed 's/<REGION>/'${REGION}'/g'  "${SCRIPT_PATH}/../templates/terraform-backend.tf.tmpl" | \
sed 's/<BUCKET_NAME>/'${S3_BUCKET}'/g' | \
sed 's/<BUCKET_KEY>/'${BUCKET_KEY}'/g'  | \
sed 's/<DYNAMODB_TABLE>/'${DYNAMODB_TABLE}'/g' \
  > ${BACKEND_TF}

# Generate the locals for terraform state
echo "Generating the terraform state local file 'pkg/tfstate/tfstate-locals.tf'."
sed 's/<REGION>/'${REGION}'/g'  ./pkg/templates/tfstate-locals.tf.tmpl | \
sed 's/<BUCKET_NAME>/'${S3_BUCKET}'/g' | \
sed 's/<BUCKET_KEY>/'${BUCKET_KEY}'/g'  | \
sed 's/<DYNAMODB_TABLE>/'${DYNAMODB_TABLE}'/g' \
  > ${TFSTATE_LOCALS}
