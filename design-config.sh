#!/usr/bin/env bash

echo "Enter foundation name [toolsmiths-pas]: "
read FOUNDATION
echo "Enter Pivnet product slug [p-rabbitmq]: "
read SLUG
#echo "Enter tile config temp dir [~/workspace/platform-automation]: "
#read CONFIG_HOME
echo "Enter secrets home dir [~/workspace/platform-automation-private]: "
read SECRETS_HOME

# Set inputs or defaults
FOUNDATION=${FOUNDATION:-toolsmiths-pas}
SLUG=${SLUG:-p-rabbitmq}
#CONFIG_HOME=${CONFIG_HOME:-~/workspace/platform-automation}
SECRETS_HOME=${SECRETS_HOME:-~/workspace/platform-automation-private}
SECRETS_FILE_COMMON=${SECRETS_HOME}/${FOUNDATION}/common.yml
SECRETS_FILE=${SECRETS_HOME}/${FOUNDATION}/${SLUG}.yml
#TEMP_DIR=${TEMP_DIR:-_tmp}
TEMP_DIR=_tmp

# Confirm
echo "Designing config using:"
echo "     secrets files:   ${SECRETS_FILE_COMMON}"
echo "                      ${SECRETS_FILE}"
echo "     tmp dir:         ${TEMP_DIR}"
echo " Continue? [Y/N]: "
read GO

if [[ $GO != "Y" ]]; then
    echo "Aborting fly set-pipeline..."
    return -print 2>/dev/null || exit 1
fi

if [[ ! -f ${SECRETS_FILE_COMMON} || ! -f ${SECRETS_FILE} ]]; then
    echo "Error: secrets files specified above must exist"
    return -print 2>/dev/null || exit 1
fi

PIVNET_API_TOKEN=$(om interpolate \
      --config ${SECRETS_FILE_COMMON} \
      --path /pivnet_api_token)

BUILD=$(om interpolate \
      --config ${SECRETS_FILE} \
      --path /product_build)

VERSION=$(om interpolate \
      --config ${SECRETS_FILE} \
      --path /product_version)

GLOB=$(om interpolate \
      --config ${SECRETS_FILE} \
      --path /pivnet_file_glob)

CONFIG_TEMPLATE=$(om interpolate \
      --config ${SECRETS_FILE_COMMON} \
      --path /config_file)

VARS_FILES=$(om interpolate \
      --config ${SECRETS_FILE_COMMON} \
      --path /vars_files)

OPS_FILES=$(om interpolate \
      --config ${SECRETS_FILE} \
      --path /ops_files)

# Get tile config template
echo "Getting config template from PivNet"
rm -rf ${TEMP_DIR}
mkdir ${TEMP_DIR}
om config-template \
  --output-directory ${TEMP_DIR} \
  --pivnet-api-token "${PIVNET_API_TOKEN}" \
  --pivnet-product-slug "${SLUG}" \
  --product-version "${VERSION}" \
  --product-file-glob "${GLOB}"
printf "\nConfig template copied to ${TEMP_DIR}\n\n"

# Parse vars files
vars_files_args=("")
for vf in ${VARS_FILES}
do
  vars_files_args+=("--vars-file ${vf}")
done

# Parse options files
if [ "${OPS_FILES}" == "null" ]; then
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
ln -s ${SLUG}/${BUILD}/ vars

echo "working_dir: ${PWD}"
echo "secrets: ${SECRETS_FILE}"
echo "config: vars/${CONFIG_TEMPLATE}"
echo "vars_files: ${vars_files_args[@]}"
echo "ops_files: ${ops_files_args[@]}"

printf "\nGiven your tile config file, the following parameters need to be defined:\n\n"

om interpolate --config vars/${CONFIG_TEMPLATE} \
               ${ops_files_args[@]} \
               ${vars_files_args[@]} \
               --vars-file ${SECRETS_FILE} \
               > /dev/null

popd > /dev/null

# Generate list of additional variables for which values need to be provided.
printf "\n\n----------\nNext steps:\n"

printf "\n1. Satisfied with your configuration? Copy parameters listed above to your config files\n"
printf "   (common and/or tile-specific) and provide values as needed\n\n"

printf "\n2. Otherwise, change the list of \"ops_files\" in your tile config file and re-run this\n"
printf "   script until you are satisfied with your configuration\n"
printf "     - For a list of ops_files to choose from, see the _tmp directory created by this script"

printf "\n"
