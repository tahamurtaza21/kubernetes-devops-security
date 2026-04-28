#!/bin/bash

echo $imageName #getting Image name from env variable

docker run --rm -v /var/lib/trivy-cache:/root/.cache/ \
  -e TRIVY_DB_REPOSITORY=ghcr.io/aquasecurity/trivy-db \
  -e TRIVY_JAVA_DB_REPOSITORY=ghcr.io/aquasecurity/trivy-java-db \
  aquasec/trivy:latest image --exit-code 0 --severity LOW,MEDIUM,HIGH $imageName

docker run --rm -v /var/lib/trivy-cache:/root/.cache/ \
  -e TRIVY_DB_REPOSITORY=ghcr.io/aquasecurity/trivy-db \
  -e TRIVY_JAVA_DB_REPOSITORY=ghcr.io/aquasecurity/trivy-java-db \
  aquasec/trivy:latest image --exit-code 1 --severity CRITICAL $imageName

#docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy:0.17.2 -q image --exit-code 0 --severity LOW,MEDIUM,HIGH --light $imageName
#docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy:0.17.2 -q image --exit-code 1 --severity CRITICAL --light $imageName

    # Trivy scan result processing
    exit_code=$?
    echo "Exit Code : $exit_code"

    # Check scan results
    if [[ ${exit_code} == 1 ]]; then
        echo "Image scanning failed. Vulnerabilities found"
        exit 1;
    else
        echo "Image scanning passed. No vulnerabilities found"
    fi;