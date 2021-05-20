#!/bin/sh

set -o errexit

TERRASCAN_SERVER="https://${SERVICE_NAME}"
IAC=${IAC_TYPE:-"k8s"}
IAC_VERSION=${IAC_VERSION:-"v1"}
CLOUD_PROVIDER=${CLOUD_PROVIDER:-"all"}
REMOTE_TYPE=${REMOTE_TYPE:-"git"}

if [ -z ${SERVICE_NAME} ]; then 
    echo "Service Name Not set" 
    exit 6
fi

if [ -z ${REMOTE_URL} ]; then
    echo "Remote URL Not set"
    exit 6
fi

SCAN_URL="${TERRASCAN_SERVER}/v1/${IAC}/${IAC_VERSION}/${CLOUD_PROVIDER}/remote/dir/scan"

echo "Connecting to the service: ${SERVICE_NAME} to scan the remote url: ${REMOTE_URL} \
  with configurations { IAC type: ${IAC}, IAC version: ${IAC_VERSION},  remote type: ${REMOTE_TYPE} , cloud provider: ${CLOUD_PROVIDER}}"


RESPONSE=$(curl -s -w \\n%{http_code} --location -k  --request POST "$SCAN_URL" \
--header 'Content-Type: application/json' \
--data-raw '{
"remote_type":"'${REMOTE_TYPE}'",
"remote_url":"'${REMOTE_URL}'"
}')

echo "$RESPONSE"

HTTP_STATUS=$(printf '%s\n' "$RESPONSE" | tail -n1)

if [ "$HTTP_STATUS" -eq 403 ]; then
    exit 3
elif [ "$HTTP_STATUS" -eq 200 ]; then
    exit 0
else
    exit 1
fi