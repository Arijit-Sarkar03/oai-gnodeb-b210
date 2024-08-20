#!/bin/bash

# Exit on error, undefined variable, or pipeline error
set -euo pipefail

# Directories and default values
PREFIX=/opt/oai-gnb
CUSTOM=/mnt/conf
ENABLE_X2=${ENABLE_X2:-yes}
THREAD_PARALLEL_CONFIG=${THREAD_PARALLEL_CONFIG:-PARALLEL_SINGLE_THREAD}

# Select the appropriate configuration template based on environment variables
if [[ -v USE_NSA_TDD_MONO ]]; then 
    cp $CUSTOM/etc/gnb.nsa.tdd.conf $PREFIX/etc/gnb.conf 
elif [[ -v USE_SA_TDD_MONO ]]; then 
    cp $CUSTOM/etc/gnb.sa.tdd.conf $PREFIX/etc/gnb.conf 
elif [[ -v USE_SA_TDD_MONO_B2XX ]]; then 
    cp $CUSTOM/etc/gnb.sa.tdd.b2xx.conf $PREFIX/etc/gnb.conf 
elif [[ -v USE_SA_FDD_MONO ]]; then 
    cp $CUSTOM/etc/gnb.sa.fdd.conf $PREFIX/etc/gnb.conf 
elif [[ -v USE_SA_CU ]]; then 
    cp $CUSTOM/etc/gnb.sa.cu.conf $PREFIX/etc/gnb.conf 
elif [[ -v USE_SA_TDD_DU ]]; then 
    cp $CUSTOM/etc/gnb.sa.du.tdd.conf $PREFIX/etc/gnb.conf 
elif [[ -v USE_SA_NFAPI_VNF ]]; then 
    cp $CUSTOM/etc/gnb.sa.nfapi.vnf.conf $PREFIX/etc/gnb.conf 
elif [[ -v USE_VOLUMED_CONF ]]; then 
    cp $CUSTOM/etc/mounted.conf $PREFIX/etc/gnb.conf 
fi

# Default Parameters
GNB_ID=${GNB_ID:-e00}
NSSAI_SD=${NSSAI_SD:-ffffff}

# Resolve AMF IP address if given as FQDN
if [[ -v AMF_IP_ADDRESS ]]; then
    if [[ "${AMF_IP_ADDRESS}" =~ [a-zA-Z] ]]; then
        AMF_IP_ADDRESS_RESOLVED=$(getent hosts $AMF_IP_ADDRESS | awk '{print $1}' || true)
        if [[ -z "$AMF_IP_ADDRESS_RESOLVED" ]]; then 
            echo "Error: Unable to resolve AMF FQDN" 
            exit 1 
        fi
        AMF_IP_ADDRESS=$AMF_IP_ADDRESS_RESOLVED
    fi
fi

# Process the configuration file
CONFIG_FILES=$(ls $PREFIX/etc/gnb.conf || true)

for c in ${CONFIG_FILES}; do
    # Check if the config file has any placeholders
    if ! grep -oP '@[a-zA-Z0-9_]+@' ${c}; then
        echo "Configuration is already set"
        break
    fi

    # Find all placeholders and create sed expressions for substitution
    VARS=$(grep -oP '@[a-zA-Z0-9_]+@' ${c} | sort | uniq | xargs)
    EXPRESSIONS=""

    for v in ${VARS}; do
        NEW_VAR=$(echo $v | sed -e "s#@##g")
        if [[ -z "${!NEW_VAR:-}" ]]; then
            echo "Error: Environment variable '${NEW_VAR}' is not set." \
                 "Config file '$(basename $c)' requires all of $VARS."
            exit 1
        fi
        EXPRESSIONS="${EXPRESSIONS};s|${v}|${!NEW_VAR}|g"
    done
    EXPRESSIONS="${EXPRESSIONS#';'}"

    # Replace placeholders in the config file
    sed -i "${EXPRESSIONS}" ${c}

    echo "=================================="
    echo "== Configuration file: ${c}"
    cat ${c}
done

# Load the USRP binaries if needed
echo "=================================="
echo "== Load USRP binaries"
if [[ -v USE_B2XX ]]; then
    $PREFIX/bin/uhd_images_downloader.py -t b2xx
elif [[ -v USE_X3XX ]]; then
    $PREFIX/bin/uhd_images_downloader.py -t x3xx
elif [[ -v USE_N3XX ]]; then
    $PREFIX/bin/uhd_images_downloader.py -t n3xx
fi

# Enable printing of stack traces on assert
export gdbStacks=1

# Start the gNB soft modem
echo "=================================="
echo "== Starting gNB soft modem"
if [[ -v USE_ADDITIONAL_OPTIONS ]]; then
    echo "Additional option(s): ${USE_ADDITIONAL_OPTIONS}"
    new_args=("$@")
    for word in ${USE_ADDITIONAL_OPTIONS}; do
        new_args+=("$word")
    done
    echo "${new_args[@]}"
    exec "${new_args[@]}"
else
    echo "$@"
    exec "$@"
fi
