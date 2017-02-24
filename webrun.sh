#!/bin/bash -x

AUTH=$(wsk property get --auth | awk '{printf("%s", $3)}' | openssl base64 | tr -d "\n") \
&& NAMESPACE="$1" && ACTION="$2" \
&& curl -s -H "Content-Type: application/json" \
-H "Authorization: Basic $AUTH" \
-X POST "https://openwhisk.ng.bluemix.net/api/v1/namespaces/${NAMESPACE}/actions/${ACTION}?blocking=true" \
-d '{"redis_host": "123"}'
