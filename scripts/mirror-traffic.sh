#!/bin/bash

# Traffic Mirroring Script

set -e

# Check arguments
if [ $# -lt 2 ]; then
    echo "Usage: $0 <service-name> <target-version> [mirror-percentage]"
    echo "Example: $0 product-service v2 50"
    exit 1
fi

SERVICE_NAME=$1
TARGET_VERSION=$2
MIRROR_PERCENTAGE=${3:-100}
NAMESPACE="microservices"

# Validate inputs
if [[ ! $MIRROR_PERCENTAGE =~ ^[0-9]+$ ]] || [ $MIRROR_PERCENTAGE -lt 0 ] || [ $MIRROR_PERCENTAGE -gt 100 ]; then
    echo "Error: Mirror percentage must be a number between 0 and 100"
    exit 1
fi

# Create a temporary virtual service file
TMP_FILE=$(mktemp)
cat > $TMP_FILE <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: ${SERVICE_NAME}-mirror
  namespace: ${NAMESPACE}
spec:
  hosts:
  - ${SERVICE_NAME}
  http:
  - route:
    - destination:
        host: ${SERVICE_NAME}
        subset: v1
    mirror:
      host: ${SERVICE_NAME}-${TARGET_VERSION}
    mirrorPercentage:
      value: ${MIRROR_PERCENTAGE}
EOF

# Apply the virtual service
echo "Applying traffic mirroring for ${SERVICE_NAME} to version ${TARGET_VERSION} (${MIRROR_PERCENTAGE}%)..."
kubectl apply -f $TMP_FILE

# Clean up
rm $TMP_FILE

# Check if destination rule exists, if not create it
if ! kubectl get destinationrule ${SERVICE_NAME} -n ${NAMESPACE} &> /dev/null; then
    echo "Creating destination rule for ${SERVICE_NAME}..."
    cat > $TMP_FILE <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: ${SERVICE_NAME}
  namespace: ${NAMESPACE}
spec:
  host: ${SERVICE_NAME}
  subsets:
  - name: v1
    labels:
      version: v1
EOF
    kubectl apply -f $TMP_FILE
    rm $TMP_FILE
fi

# Display instructions
echo "Traffic mirroring configured successfully."
echo "- ${MIRROR_PERCENTAGE}% of requests to ${SERVICE_NAME} will be mirrored to ${SERVICE_NAME}-${TARGET_VERSION}"
echo "- The mirrored traffic is 'fire and forget' - responses will be ignored"
echo "- Original traffic continues to be served by ${SERVICE_NAME} v1"
echo
echo "You can now monitor the behavior of the ${TARGET_VERSION} without affecting users."
echo "Check logs from both services to compare behavior." 