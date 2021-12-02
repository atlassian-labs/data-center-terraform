# This script will generate/override the `./pkg/tfstate/tfstate-locals.tf` and `./terraform-backend.tf`


SCRIPT_PATH=$(dirname "$0")
if [ $# -lt 1 ]; then
  echo $#
      echo "The terraform config filename for infrastructure is missing."
      echo
      echo "Usage: generate-variables.sh <config_file> [<path_to_root>]"
      exit 1
fi


CONFIG_FILE="${1}"
if [ $# -eq 1 ]; then
  ROOT_FOLDER="$(pwd)"
else
  ROOT_FOLDER="${2}"
fi

BACKEND_TF="${ROOT_FOLDER}/terraform-backend.tf"
TFSTATE_LOCALS="${ROOT_FOLDER}/pkg/tfstate/tfstate-locals.tf"
ASG_EC2_TAG_PATH="${ROOT_FOLDER}/pkg/modules/AWS/asg_ec2_tagging"

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



# fetch the config files from root
cp -fr "${SCRIPT_PATH}/../../variables.tf" "${SCRIPT_PATH}/../tfstate"
cp -fr "${CONFIG_FILE}" "${SCRIPT_PATH}/../tfstate"

# copy variable files for tagging module
cp "${SCRIPT_PATH}/../../${CONFIG_FILE}" "${ASG_EC2_TAG_PATH}"
cp "${SCRIPT_PATH}/../../variables.tf" "${ASG_EC2_TAG_PATH}"
cp "${SCRIPT_PATH}/../tfstate/tfstate-locals.tf" "${ASG_EC2_TAG_PATH}"