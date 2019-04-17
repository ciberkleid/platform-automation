# Get user input
if [ -z ${1} ]; then
  echo "Enter absolute path to tile config file [~/workspace/platform-automation-private/toolsmiths-pas/p-rabbitmq.yml]: "
  read SECRETS_FILE
  SECRETS_FILE=$(eval echo ${SECRETS_FILE})
  echo "Enter temp dir [_tmp]: "
  read TEMP_DIR
else
  SECRETS_FILE=$1
fi
# Set variables
SECRETS_FILE=${SECRETS_FILE:-~/workspace/platform-automation-private/toolsmiths-pas/p-rabbitmq.yml}
TEMP_DIR=${TEMP_DIR:-_tmp}

SLUG=$(om interpolate \
      --config ${SECRETS_FILE} \
      --path /pivnet_product_slug)

VERSION=$(om interpolate \
      --config ${SECRETS_FILE} \
      --path /product_build)

CONFIG_TEMPLATE=$(om interpolate \
      --config ${SECRETS_FILE} \
      --path /config_file)

VARS_FILES=$(om interpolate \
      --config ${SECRETS_FILE} \
      --path /vars_files)

OPS_FILES=$(om interpolate \
      --config ${SECRETS_FILE} \
      --path /ops_files)

# Clone tile-config-generator output from GitHub
TCG=${TEMP_DIR}/vars

if [ ! -f ${TCG}/${SLUG}/${VERSION}/product.yml ]; then
    cat ${TCG}/${SLUG}/${VERSION}/product.yml
    if [ -d ${TCG} ]; then rm -rf ${TCG}; fi
    mkdir -p ${TCG}
    git clone --quiet git@github.com:ciberkleid/tile-configuration.git ${TCG}
    printf "\nCloned tile-configuration repo into ${TCG}\n\n"
fi

# Parse vars files
vars_files_args=("")
for vf in ${VARS_FILES}
do
  vars_files_args+=("--vars-file ${vf}")
done

# Parse options files
if [ ${OPS_FILES} == "null" ]; then
    rm -f ${TEMP_DIR}/vars/empty-file.yml
    touch ${TEMP_DIR}/vars/empty-file.yml
    OPS_FILES=empty-file.yml
fi
ops_files_args=("")
for of in ${OPS_FILES}
do
  ops_files_args+=("--ops-file vars/${of}")
done

printf "\nRunning designer with the following env setup:\n\n"

pushd ${TEMP_DIR} > /dev/null

echo "working_dir: ${PWD}"
echo "config: vars/${CONFIG_TEMPLATE}"
echo "ops_files: ${ops_files_args[@]}"
echo "vars_files: ${vars_files_args[@]}"
echo "secrets: ${SECRETS_FILE}"

printf "\nGiven your tile config file, the following parameters need to be defined:\n\n"

om interpolate --config vars/${CONFIG_TEMPLATE} \
               ${ops_files_args[@]} \
               ${vars_files_args[@]} \
               --vars-file ${SECRETS_FILE} \
               > /dev/null

popd > /dev/null

# Generate list of additional variables for which values need to
# be provided.
printf "\n\n----------\nNext steps:\n"

printf "\n1. If you are satisfied with your configuration, copy any parameters listed above to your tile config\n"
printf "   file and provide values as needed\n\n"

printf "\n2. Otherwise, change the list of \"ops_files\" in your tile config file and re-run this script until\n"
printf "   you are satisfied with your configuration\n"
printf "     - For a list of ops_files to choose from, see https://github.com/ciberkleid/tile-configuration or use\n"
printf "       the tile-config-generator tool to extract config options from a *.pivotal file\n"
printf "       (tile-config-generator is available at https://github.com/pivotalservices/tile-config-generator)\n"
printf "     - If you are using the tile-config-generator tool, make sure the files you choose are also available\n"
printf "       on https://github.com/ciberkleid/tile-configuration\n"

printf "\n"
