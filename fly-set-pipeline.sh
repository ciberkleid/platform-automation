# Get user input
echo "Enter foundation name [toolsmiths-pas]: "
read FOUNDATION
echo "Enter Pivnet product slug [p-rabbitmq]: "
read SLUG
echo "Enter tile config home dir [~/workspace/platform-automation]: "
read CONFIG_HOME
echo "Enter secrets home dir [~/workspace/platform-automation-private]: "
read SECRETS_HOME

# Set inputs or defaults
FOUNDATION=${FOUNDATION:-toolsmiths-pas}
SLUG=${SLUG:-p-rabbitmq}
CONFIG_HOME=${CONFIG_HOME:-~/workspace/platform-automation}
SECRETS_HOME=${SECRETS_HOME:-~/workspace/platform-automation-private}

# Set fly command variables
PIPELINE_NAME=${FOUNDATION}-${SLUG}
PIPELINE_CONFIG_FILE=${CONFIG_HOME}/${foundation}/pipeline-parameterized.yml
TILE_SELECTOR_FILE=${CONFIG_HOME}/${foundation}/${SLUG}-selector.yml
SECRETS_FILE_COMMON=${SECRETS_HOME}/${foundation}-common.yml
SECRETS_FILE_SLUG=${SECRETS_HOME}/${foundation}-${SLUG}.yml

# Confirm
echo "Setting pipeline using:"
echo "     pipeline name:   ${PIPELINE_NAME}"
echo "     pipeline config: ${PIPELINE_CONFIG_FILE}"
echo "     selector file:   ${TILE_SELECTOR_FILE}"
echo "     secrets files:   ${SECRETS_FILE_COMMON}"
echo "                      ${SECRETS_FILE_SLUG}"
echo " Continue? [Y/N]: "
read GO

if [[ $GO == "Y" ]]; then

    TEMP_FILE=_tmp/${FOUNDATION}-env.yml
    mkdir -p "$(dirname "$TEMP_DIR")"
    om interpolate --config ${CONFIG_HOME}/${FOUNDATION}/config/templates/env.yml \
                   --vars-file ${SECRETS_FILE_COMMON} \
                   > ${TEMP_FILE}

    fly -t w sp -p ${PIPELINE_NAME} \
                -c ${PIPELINE_CONFIG_FILE} \
                -l ${TILE_SELECTOR_FILE} \
                -l ${SECRETS_FILE_COMMON} \
                -l ${SECRETS_FILE_SLUG}

    #rm ${TEMP_FILE}

fi
