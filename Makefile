.PHONY: all build run setup list_targets log

NAMESPACE = ibm1@19ft.com_craft

choose: build-choose run-web-choose
counts: build-counts run-web-counts


# ------------------------------------------------------------------------------
# targets for  choose action

build-choose:
	cat lib/Redis/Redis*.swift actions/_common.swift actions/choose.swift > build/choose.swift
	wsk action update DC/choose build/choose.swift \
		--annotation description 'Choose me a drink' \
		--annotation final true --annotation web-export true

# CLI: curl -i -H 'Accept: application/json' https://openwhisk.ng.bluemix.net/api/v1/experimental/web/ibm1@19ft.com_craft/DC/choose.http
run-web-choose:
	curl -s -i -H 'Content-Type: application/json' -H 'Accept: application/json' \
	https://openwhisk.ng.bluemix.net/api/v1/experimental/web/$(NAMESPACE)/DC/choose.http \

run-action-choose:
	-wsk action invoke --blocking --result DC/choose --param type hot

# Call the API endpoint: api_url=`wsk api-experimental list | grep DC/choose | awk 'END {print $NF}'`; curl -i $api_url;
create-api-endpoint-choose:
	wsk api-experimental create /DC/choose get DC/choose


# ------------------------------------------------------------------------------
# targets for counts action

build-counts:
	cat actions/_common.swift actions/counts.swift > build/counts.swift
	wsk action update DC/counts build/counts.swift \
		--annotation description 'Count the drinks' \
		--annotation final true --annotation web-export true

# CLI: curl -i -H 'Accept: application/json' https://openwhisk.ng.bluemix.net/api/v1/experimental/web/ibm1@19ft.com_craft/DC/counts.http
run-web-counts:
	curl -s -i -H 'Content-Type: application/json' -H 'Accept: application/json' \
	https://openwhisk.ng.bluemix.net/api/v1/experimental/web/$(NAMESPACE)/DC/counts.http \

run-action-counts:
	-wsk action invoke --blocking --result DC/counts

# Call the API endpoint: api_url=`wsk api-experimental list | grep DC/count | awk 'END {print $NF}'`; curl -i $api_url;
create-api-endpoint-counts:
	wsk api-experimental create /DC/counts get DC/counts



# ------------------------------------------------------------------------------
# targets for incrementDrinkCount action

build-increment-drink-count:
	cat lib/Redis/Redis*.swift actions/_common.swift actions/incrementDrinkCount.swift > build/incrementDrinkCount.swift
	wsk action update DC/incrementDrinkCount build/incrementDrinkCount.swift \
		--annotation description 'Increment the drink counter' \
		--annotation final true --annotation web-export true

run-action-increment-drink-count:
	-wsk action invoke --blocking --result DC/incrementDrinkCount  --param name "A test drink"


# ------------------------------------------------------------------------------
# misc

lastlog:
	wsk activation list -l1 | tail -n1 | cut -d ' ' -f1 | xargs wsk activation logs

setup:
	# Create package
	wsk package update DC --param-file parameters.json


