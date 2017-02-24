.PHONY: all build run setup list_targets log

NAMESPACE = ibm1@19ft.com_craft

choose: build-choose run-web-choose
counts: build-counts run-web-counts


# ------------------------------------------------------------------------------
# targets for  choose action

build-choose:
	cat lib/Redis/Redis*.swift actions/choose.swift > build/choose.swift
	wsk action update DC/choose build/choose.swift \
		--annotation description 'Choose me a drink' \
		--annotation final true --annotation web-export true

run-web-choose:
	curl -s -i -H 'Content-Type: application/json' -H 'Accept: application/json' \
	https://openwhisk.ng.bluemix.net/api/v1/experimental/web/$(NAMESPACE)/DC/choose.json

run-action-choose:
	-wsk action invoke --blocking --result DC/choose --param type hot

# Call the API endpoint: api_url=`wsk api-experimental list | grep DC/choose | awk 'END {print $NF}'`; curl $api_url;  echo ""
create-api-endpoint-choose:
	wsk api-experimental create /DC/choose get DC/choose


# ------------------------------------------------------------------------------
# targets for counts action

build-counts:
	cat lib/Redis/Redis*.swift actions/counts.swift > build/counts.swift
	wsk action update DC/counts build/counts.swift \
		--annotation description 'Count the drinks' \
		--annotation final true --annotation web-export true

run-web-counts:
	curl -s -i -H 'Content-Type: application/json' -H 'Accept: application/json' \
	https://openwhisk.ng.bluemix.net/api/v1/experimental/web/$(NAMESPACE)/DC/counts.json


run-action-counts:
	-wsk action invoke --blocking --result DC/counts  --param type hot

# Call the API endpoint: api_url=`wsk api-experimental list | grep DC/count | awk 'END {print $NF}'`; curl $api_url;  echo ""
create-api-endpoint-counts:
	wsk api-experimental create /DC/counts get DC/counts



# ------------------------------------------------------------------------------
# misc

lastlog:
	wsk activation list -l1 | tail -n1 | cut -d ' ' -f1 | xargs wsk activation logs

setup:
	# Create package
	wsk package update DC --param-file parameters.json


