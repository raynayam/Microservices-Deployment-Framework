#!/bin/bash

# Canary Deployment Script

set -e

# Check arguments
if [ $# -lt 3 ]; then
    echo "Usage: $0 <service-name> <version> <traffic-percentage>"
    echo "Example: $0 user-service v2 20"
    exit 1
fi

SERVICE_NAME=$1
VERSION=$2
TRAFFIC_PERCENTAGE=$3
NAMESPACE="microservices"

# Validate inputs
if [[ ! $TRAFFIC_PERCENTAGE =~ ^[0-9]+$ ]] || [ $TRAFFIC_PERCENTAGE -lt 0 ] || [ $TRAFFIC_PERCENTAGE -gt 100 ]; then
    echo "Error: Traffic percentage must be a number between 0 and 100"
    exit 1
fi

# Create a temporary virtual service file
TMP_FILE=$(mktemp)
cat > $TMP_FILE <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: ${SERVICE_NAME}
  namespace: ${NAMESPACE}
spec:
  hosts:
  - ${SERVICE_NAME}
  http:
  - route:
    - destination:
        host: ${SERVICE_NAME}
        subset: v1
      weight: $((100 - $TRAFFIC_PERCENTAGE))
    - destination:
        host: ${SERVICE_NAME}
        subset: ${VERSION}
      weight: ${TRAFFIC_PERCENTAGE}
EOF

# Apply the virtual service
echo "Applying canary deployment for ${SERVICE_NAME} (${VERSION}) with ${TRAFFIC_PERCENTAGE}% traffic..."
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
  - name: ${VERSION}
    labels:
      version: ${VERSION}
EOF
    kubectl apply -f $TMP_FILE
    rm $TMP_FILE
fi

echo "Canary deployment complete. ${TRAFFIC_PERCENTAGE}% of traffic is now routed to ${SERVICE_NAME} ${VERSION}."
echo "Monitor the service using Prometheus/Grafana to evaluate the new version."
echo "Once verified, you can increase the traffic percentage or set it to 100 to complete the rollout." 