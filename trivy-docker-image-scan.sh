#!/bin/bash

echo "Scanning base image..."

docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy:latest --exit-code 0 --severity HIGH eclipse-temurin:8-jdk-alpine

docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy:latest --exit-code 1 --severity CRITICAL eclipse-temurin:8-jdk-alpine

exit_code=$?
echo "Exit Code : $exit_code"

if [[ "${exit_code}" == 1 ]]; then
    echo "Image scanning failed. Vulnerabilities found"
    exit 1
else
    echo "Image scanning passed. No CRITICAL vulnerabilities found"
fi