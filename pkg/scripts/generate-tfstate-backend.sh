# This script will generate and override the `./pkg/tfstate/tfstate-locals.tf` and `./terraform-backend.tf`

SCRIPT_PATH=$(dirname "$0")
if [ ! $# -eq 2 ]; then
      echo "The filename for terraform backend and tfstate local variable are missing."
      echo
      echo "Usage: generate-tfstate-backend.sh <path_to_root/backend-terraform.tf> <path_to_tfstate/tfstate-local.tf>"
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

# Generates the unique bucket and table names for the deployment of tfstate using AWS account ID
S3_BUCKET="atlassian-data-center-terraform-state-${AWS_ACCOUNT_ID}"
DYNAMODB_TABLE="${ENVIRONMENT_NAME}_${PRODUCT}_${AWS_ACCOUNT_ID}"
BUCKET_KEY="${ENVIRONMENT_NAME}-${PRODUCT}-${AWS_ACCOUNT_ID}"

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
