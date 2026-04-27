#!/bin/bash

echo "Scanning base image..."

docker run --rm -v /var/lib/trivy-cache:/root/.cache/ \
  -e TRIVY_DB_REPOSITORY=ghcr.io/aquasecurity/trivy-db \
  -e TRIVY_JAVA_DB_REPOSITORY=ghcr.io/aquasecurity/trivy-java-db \
  aquasec/trivy:latest image --exit-code 0 --severity HIGH eclipse-temurin:8-jdk

docker run --rm -v /var/lib/trivy-cache:/root/.cache/ \
  -e TRIVY_DB_REPOSITORY=ghcr.io/aquasecurity/trivy-db \
  -e TRIVY_JAVA_DB_REPOSITORY=ghcr.io/aquasecurity/trivy-java-db \
  aquasec/trivy:latest image --exit-code 1 --severity CRITICAL eclipse-temurin:8-jdk

docker run --rm -v /var/lib/trivy-cache:/root/.cache/ \
  -e TRIVY_DB_REPOSITORY=ghcr.io/aquasecurity/trivy-db \
  -e TRIVY_JAVA_DB_REPOSITORY=ghcr.io/aquasecurity/trivy-java-db \
  aquasec/trivy:latest image --severity CRITICAL python:3.4-alpine

exit_code=$?
echo "Exit Code : $exit_code"

if [[ "${exit_code}" == 1 ]]; then
    echo "Image scanning failed. Vulnerabilities found"
    exit 1
else
    echo "Image scanning passed. No CRITICAL vulnerabilities found"
fi