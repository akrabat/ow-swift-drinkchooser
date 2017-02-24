.PHONY: all build run setup list_targets log


all: build run log

build:
	wsk action update DC/choose actions/choose.swift

run:
	-wsk action invoke --blocking --result DC/choose  --param type hot


log:
	wsk activation list -l1 | tail -n1 | cut -d ' ' -f1 | xargs wsk activation logs

setup:
	# Create package
	wsk package update DC

api-endpoint:
	wsk api-experimental create /DC/choose get DC/choose

	# curl -s https://719cc194-b982-4543-9d05-e357f93b58c7-gws.api-gw.mybluemix.net/DC/choose && echo ""
curl:
	api_url=`wsk api-experimental list | grep DC/choose | awk 'END {print $NF}'`; curl $$api_url;  echo ""

# Provide a list of all targets
list_targets:
	@echo "Available targets:"
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | xargs

