# This script will generate and override the `./pkg/tfstate/tfstate-locals.tf` and `./terraform-backend.tf`
# to skip this part you can pass `-skip` as the parameter when you run this script

SCRIPT_PATH=$(dirname "$0")
if [ ! $# -eq 2 ]; then
      echo "The filename for terraform backend and tfstate local variable are missing."
      exit 1
fi

BACKEND_TF="${1}"
TFSTATE_LOCALS="${2}"

LOCAL_TF="${SCRIPT_PATH}/../../locals.tf"


# extract S3 bucket, dynamodb, tags, and region from locals.tf
ENVIRONMENT_NAME=$(grep 'environment_name' ${LOCAL_TF} | sed -nE 's/^.*"(.*)".*$/\1/p')
REGION=$(grep 'region' ${LOCAL_TF} | sed -nE 's/^.*"(.*)".*$/\1/p')

# Get the AWS account ID
ACCOUNTID=$(aws sts get-caller-identity --query Account --output text)

# Generate generate unique bucket and table names for the deployment of tfstate using AWS account ID
S3_BUCKET="dc-terraform-${ACCOUNTID}"
DYNAMODB_TABLE="${ENVIRONMENT_NAME}_${PRODUCT}_${ACCOUNTID}"
BUCKET_KEY="${ENVIRONMENT_NAME}-${PRODUCT}-${ACCOUNTID}"

# Generate the terraform backend, where terraform store the state of the infrastructure
echo "Generating the terraform backend definition file."
sed 's/<REGION>/'${REGION}'/g'  "${SCRIPT_PATH}/../templates/terraform-backend.tf.tmpl" | \
sed  's/<BUCKET_NAME>/'${S3_BUCKET}'/g' | \
sed 's/<BUCKET_KEY>/'${BUCKET_KEY}'/g'  | \
sed 's/<DYNAMODB_TABLE>/'${DYNAMODB_TABLE}'/g' \
  > ${BACKEND_TF}

# Generate the locals for terraform state
echo "Generating the terraform state local file."
sed 's/<REGION>/'${REGION}'/g'  ./pkg/templates/tfstate-locals.tf.tmpl | \
sed  's/<BUCKET_NAME>/'${S3_BUCKET}'/g' | \
sed 's/<BUCKET_KEY>/'${BUCKET_KEY}'/g'  | \
sed 's/<DYNAMODB_TABLE>/'${DYNAMODB_TABLE}'/g' \
  > ${TFSTATE_LOCALS}
