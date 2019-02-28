# Get user input
if [ -z ${1} ]; then
  echo "Enter designer file [p-rabbitmq-designer.yml]: "
  read DESIGNER
  echo "Enter temp dir [_tmp]: "
  read TEMP_DIR
  #echo "Enter secrets file [~/workspace/platform-automation-private/toolsmiths-pas-p-rabbitmq.yml]: "
  #read SECRETS
else
  DESIGNER=$1
fi
# Set variables
DESIGNER=${DESIGNER:-p-rabbitmq-designer.yml}
TEMP_DIR=${TEMP_DIR:-_tmp}
#SECRETS=${SECRETS:-~/workspace/platform-automation-private/toolsmiths-pas-p-rabbitmq.yml}
SLUG=$(om interpolate \
      --config ${DESIGNER} \
      --path /pivnet_product_slug)

VERSION=$(om interpolate \
      --config ${DESIGNER} \
      --path /product_version)

CONFIG_FILE=$(om interpolate \
      --config ${DESIGNER} \
      --path /config_file)

VARS_FILES=$(om interpolate \
      --config ${DESIGNER} \
      --path /vars_files)

OPS_FILES=$(om interpolate \
      --config ${DESIGNER} \
      --path /ops_files)

# Clone tile-config-generator output from GitHub
TCG=${TEMP_DIR}/vars

if [ ! -f ${TCG}/${SLUG}/${VERSION}/product.yml ]; then
    if [ -d ${TCG} ]; then rmdir ${TCG}; fi
    mkdir -p ${TCG}
    git clone --quiet git@github.com:DaxterM/tile-configuration.git ${TCG}
    printf "\nCloned tile-configuration repo into ${TCG}\n\n"
fi

mkdir -p ${TEMP_DIR}/"$(dirname env/common/config/templates/empty-file.yml)"
touch ${TEMP_DIR}/env/common/config/templates/empty-file.yml

# Parse vars files
vars_files_args=("")
for vf in ${VARS_FILES}
do
  vars_files_args+=("--vars-file ${vf}")
done

# Parse options files
ops_files_args=("")
for of in ${OPS_FILES}
do
  ops_files_args+=("--ops-file ${of}")
done

# Create designer output file including slug, version and options files,
# as well as the  list of additional variables for which values need to
# be provided.
printf "\nChange the ops-files in your designer file until you have the desired configuration\n"
printf "\nCopy any parameters listed below to section 3 of your designer file\n"
printf "Follow the instructions in the header of the designer template\n\n"

pushd ${TEMP_DIR} > /dev/null

om interpolate --config vars/${CONFIG_FILE} \
               ${ops_files_args[@]} \
               ${vars_files_args[@]} \
               --vars-file ../${DESIGNER} \
               > /dev/null

popd > /dev/null

printf "\n"
