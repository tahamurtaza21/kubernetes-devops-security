#!/bin/bash

dockerImageName="tahamur27/numeric-app:${GIT_COMMIT}"
echo $dockerImageName

docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy:latest image --exit-code 0 --severity HIGH $dockerImageName
docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy:latest image --exit-code 1 --severity CRITICAL $dockerImageName

exit_code=$?
echo "Exit Code : $exit_code"

if [[ "${exit_code}" == 1 ]]; then
    echo "Image scanning failed. Vulnerabilities found"
    exit 1;
else
    echo "Image scanning passed. No CRITICAL vulnerabilities found"
fi;