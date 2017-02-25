# Drink Chooser

This is a simple Swift Serverless app which will suggest a drink when asked


## OpenWhisk authorisation:

    1. https://console.ng.bluemix.net/openwhisk/learn/cli
    2. Copy "New Authentication" command and paste into console
    3. Unset namespace: `wsk property unset --namespace`


## Notes

* You'll need a `parameters.json` - start with `parameters.json.dist`
* Edit `NAMESPACE` at the top of `Makefile`
* Read the makfile to see what to do:

    * `make setup` to create the package
    * `make build` to upload all the actions
    * `make run-choose` to have a drink recommended to you
    * `make run-counts` to view recommendation stats
    * `make lastlog` will show the last activation's log

## Actions

There are two actions:

* `choose` which will recommend a drink for you
* `counts` which will show how often the top 10 drinks have been recommended


## Useful curl commands

Note run this: `echo '-w "\n"' >> ~/.curlrc` to ensure that curl always add a new line to the end of the response for neatness 

**web action calls:**

choose: `curl -i -H 'Accept: application/json' https://openwhisk.ng.bluemix.net/api/v1/experimental/web/ibm1@19ft.com_craft/DC/choose.http`
counts: `curl -i -H 'Accept: application/json' https://openwhisk.ng.bluemix.net/api/v1/experimental/web/ibm1@19ft.com_craft/DC/counts.http`


**API Gateway calls:**

choose: `curl -i -H 'Accept: application/json' https://de0023cf-edae-4132-89c4-9bdd57bab787-gws.api-gw.mybluemix.net/DC/choose`
counts: `curl -i -H 'Accept: application/json' https://de0023cf-edae-4132-89c4-9bdd57bab787-gws.api-gw.mybluemix.net/DC/counts`


A neat way to get the correct URL for the API Gateway calls is:

choose: api_url=`wsk api-experimental list | grep DC/choose | awk 'END {print $NF}'`; curl -i $api_url
count: api_url=`wsk api-experimental list | grep DC/count | awk 'END {print $NF}'`; curl -i $api_url
