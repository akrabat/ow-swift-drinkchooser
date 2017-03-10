# Drink Chooser

This is a simple [OpenWhisk][1] serverless app written in [Swift][2] that will
suggest a drink when asked. You can also view the top recommended drinks.

[1]: http://openwhisk.org
[2]: https://swift.org

## Actions

There are three actions available via web actions:
 
* **`choose`**: will recommend a drink for you
* **`counts`**: will show how often the top 10 drinks have been recommended
* **`slackDrink`**: expects to respond to "/drink please" and calls `choose`

There is one internal action:

* **`incrementDrinkCount`**: called from `choose` to increment the number of times
  this drink has been recommended in Redis

## Notes

* Create `parameters.json` - start with `parameters.json.dist`
  * Edit the information in `parameters.json` to connect to your Compose Redis instance
* Read the makfile to see what to do:

    * `make setup` to create the package
    * `make` to buld and upload all the actions
    * `make choose` to have a drink recommended to you
    * `make counts` to view recommendation stats
    * `make lastlog` will show the last activation's log    

### Example output

```text
$ curl -s -H 'Content-Type: application/json' -H 'Accept: application/json' \
    https://openwhisk.ng.bluemix.net/api/v1/experimental/web/{org}_{space}/DC/choose.http

{
  "recommendation": "A nice hot cup of tea!"
}
```


```text
$ curl -s -H 'Content-Type: application/json' -H 'Accept: application/json' \
https://openwhisk.ng.bluemix.net/api/v1/experimental/web/{org}_{space}/DC/counts.http

{
  "results": [
    {
      "Anijsmelk": 28
    },
    {
      "A nice hot cup of tea!": 23
    },
    {
      "Hot chocolate": 21
    },
    {
      "Espresso": 19
    },
    {
      "Bandrek": 18
    }
  ]
}
```


## Useful curl setting

```text
    $ echo '-w "\n"' >> ~/.curlrc`
```

will ensure that curl always add a new line to the end of the response for neatness 

**web action calls:**

choose: `$ curl -i -H 'Accept: application/json' https://openwhisk.ng.bluemix.net/api/v1/experimental/web/{org}_{space}/DC/choose.http`
counts: `$ curl -i -H 'Accept: application/json' https://openwhisk.ng.bluemix.net/api/v1/experimental/web/{org}_{space}/DC/counts.http`


**API Gateway calls:**

If you set up API Gateway access to the actions, then this is how you would call them:

choose: `curl -i -H 'Accept: application/json' https://{some string}-gws.api-gw.mybluemix.net/DC/choose`
counts: `curl -i -H 'Accept: application/json' https://{some string}-gws.api-gw.mybluemix.net/DC/counts`


A neat way to get the correct URL for the API Gateway calls is:

choose: 

    $ api_url=`wsk api-experimental list | grep DC/choose | awk 'END {print $NF}'`; curl -i $api_url

count: 

    $ api_url=`wsk api-experimental list | grep DC/count | awk 'END {print $NF}'`; curl -i $api_url


## OpenWhisk authorisation:

When you first start, you need to authorise your `wsk` command with OpenWhisk:

    1. https://console.ng.bluemix.net/openwhisk/learn/cli
    2. Copy "New Authentication" command and paste into console
    3. Unset namespace: `wsk property unset --namespace`

