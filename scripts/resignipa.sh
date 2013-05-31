#!/bin/bash
#
# Feel free to take, distribute, copy, install, rename, modify or
# enhance this script. I hope it comes in handy. If you have ideas
# to make it better...you know where it came from.
#
# resignipa 								  created: 31/05/2013
# ===============================================================
#
# A simple utility to resign an .ipa file using the new mobile provision
# and certifcate name specified.
#
# resignipa <.ipa filename> <.mobileprovision filename> <certificate name>

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]
	then
	echo "resignipa <.ipa filename> <.mobileprovision filename> <certificate name>"
	exit
fi

# Load up the input parameters
IPA_FILE="$1"
PROVISION_FILE="$2"
CERT_NAME="$3"

# Set up the required paths
TEMP_ROOT_DIR="resignipa"
TEMP_DIR_PATH=${TMPDIR}/${TEMP_ROOT_DIR}
mkdir -p ${TEMP_DIR_PATH}

# Locate the codesign command
CODESIGN_CMD=`which codesign`

# Unpack the .ipa and locate the Info.plist
unzip -q "${IPA_FILE}" -d ${TEMP_DIR_PATH} 
APP_NAME=`ls ${TMPDIR}/${TEMP_ROOT_DIR}/Payload`

# Remove the existing code signing
rm -r ${TEMP_DIR_PATH}/Payload/${APP_NAME}/_CodeSignature ${TEMP_DIR_PATH}/Payload/${APP_NAME}/CodeResources 2> /dev/null | true
# Copy the new profile into place.
cp "${PROVISION_FILE}" "${TEMP_DIR_PATH}/Payload/${APP_NAME}/embedded.mobileprovision"
# Re-sign
${CODESIGN_CMD} -f -s "${CERT_NAME}" --resource-rules "${TEMP_DIR_PATH}/Payload/${APP_NAME}/ResourceRules.plist" "${TEMP_DIR_PATH}/Payload/${APP_NAME}"
# Rezip the archive
zip -qr ${IPA_FILE} ${TEMP_DIR_PATH}/Payload

# Delete the temporary files
rm -rf ${TMPDIR}/${TEMP_ROOT_DIR}

echo "${IPA_FILE} re-signed"