#!/bin/bash
#
# LICENSE GOES HERE
#
# whatapp 								  	  created: 31/05/2013
# ===============================================================
#
# A simple utility to display the name and version information of
# the application that is contained within a specified .ipa file.
#
# whatapp <.ipa filename>

if [ -z "$1" ]
	then
	echo "whatapp <.ipa filename>"
	exit
fi

# Load up the input parameters
IPA_FILE="$1"

# Set up the required paths
TEMP_ROOT_DIR="whichversion"
TEMP_DIR_PATH=${TMPDIR}/${TEMP_ROOT_DIR}
mkdir -p ${TEMP_DIR_PATH}

# Unpack the .ipa and locate the Info.plist
#unzip -q "${IPA_FILE}" -d ${TEMP_DIR_PATH}
unzip -q "${IPA_FILE}" Payload/\*.app/Info.plist -d ${TEMP_DIR_PATH} 
APP_NAME=`ls ${TMPDIR}/${TEMP_ROOT_DIR}/Payload`
TEMP_PLIST_PATH="${TMPDIR}/${TEMP_ROOT_DIR}/Payload/${APP_NAME}/Info.plist"

# Find the path to the PlistBuddy binary
PLISTBUDDY_CMD=`which PlistBuddy`
if [ -z "$PLISTBUDDY_CMD" ] 
	then
	PLISTBUDDY_CMD="/usr/libexec/PlistBuddy"
fi

# Extract and store the required bundle entries
NAME=`${PLISTBUDDY_CMD} -c "Print CFBundleDisplayName" "${TEMP_PLIST_PATH}"`
BUNDLE_ID=`${PLISTBUDDY_CMD} -c "Print CFBundleIdentifier" "${TEMP_PLIST_PATH}"`
VERSION=`${PLISTBUDDY_CMD} -c "Print CFBundleVersion" "${TEMP_PLIST_PATH}"`
SHORT_VERSION=`${PLISTBUDDY_CMD} -c "Print CFBundleShortVersionString" "${TEMP_PLIST_PATH}"`

# Delete the temporary plist file
rm -rf ${TMPDIR}/${TEMP_ROOT_DIR}

# Display the application information
echo -e "\n\tApplication:\t${NAME} (${BUNDLE_ID})"
if [ "${VERSION}" == "${SHORT_VERSION}" ];
	then
	echo -e "\tVersion:\t${VERSION}\n"
else
	echo -e "\t${VERSION} (${SHORT_VERSION})\n"
fi
