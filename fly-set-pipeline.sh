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
PIPELINE_CONFIG_FILE=${CONFIG_HOME}/pipeline-parameterized.yml
SECRETS_FILE_COMMON=${SECRETS_HOME}/${FOUNDATION}/common.yml
SECRETS_FILE=${SECRETS_HOME}/${FOUNDATION}/${SLUG}.yml

# Confirm
echo "Setting pipeline using:"
echo "     pipeline name:   ${PIPELINE_NAME}"
echo "     pipeline config: ${PIPELINE_CONFIG_FILE}"
echo "     secrets files:   ${SECRETS_FILE_COMMON}"
echo "                      ${SECRETS_FILE}"
echo " Continue? [Y/N]: "
read GO

if [[ $GO == "Y" ]]; then
    fly -t w sp -p ${PIPELINE_NAME} \
                -c ${PIPELINE_CONFIG_FILE} \
                -l ${SECRETS_FILE_COMMON} \
                -l ${SECRETS_FILE} \
                --non-interactive
fi

echo "Unpause and trigger? [Y/N]: "
read GO

if [[ $GO == "Y" ]]; then
    fly -t w unpause-pipeline --pipeline ${PIPELINE_NAME}
    fly -t w trigger-job --job ${PIPELINE_NAME}/${PIPELINE_NAME}
fi
