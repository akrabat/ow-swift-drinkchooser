# Drink Chooser

This is a simple [OpenWhisk][1] serverless app written in [Swift][2] that will
suggest a drink when asked. You can also view the top recommended drinks.

[1]: http://openwhisk.org
[2]: https://swift.org

## Actions

There are two actions availble via web actions:
 
* **`choose`**: will recommend a drink for you
* **`counts`**: will show how often the top 10 drinks have been recommended


There is one internal action:

* **`incrementDrinkCount`**: called from `choose` to increment the number of times
  this drink has been recommended in Redis

## Notes

* You'll need a `parameters.json` - start with `parameters.json.dist`
* Edit `NAMESPACE` at the top of `Makefile`
* Read the makfile to see what to do:

    * `make setup` to create the package
    * `make build` to upload all the actions
    * `make run-choose` to have a drink recommended to you
    * `make run-counts` to view recommendation stats
    * `make lastlog` will show the last activation's log    

### Example output

```text
$ curl -s -i -H 'Content-Type: application/json' -H 'Accept: application/json' \
    https://openwhisk.ng.bluemix.net/api/v1/experimental/web/ibm1@19ft.com_craft/DC/choose.http

HTTP/1.1 200 OK
X-Backside-Transport: OK OK
Connection: Keep-Alive
Transfer-Encoding: chunked
Server: nginx/1.11.1
Date: Sat, 25 Feb 2017 18:14:26 GMT
Content-Type: application/json
Access-Control-Allow-Origin: *
Access-Control-Allow-Headers: Authorization, Content-Type
X-Global-Transaction-ID: 631456385
Set-Cookie: DPJSESSIONID=PBC5YS:1376290542; Path=/; Domain=.whisk.ng.bluemix.net

{
  "recommendation": "A nice hot cup of tea!"
}
```


```text
$ curl -s -i -H 'Content-Type: application/json' -H 'Accept: application/json' \
https://openwhisk.ng.bluemix.net/api/v1/experimental/web/ibm1@19ft.com_craft/DC/counts.http

HTTP/1.1 200 OK
X-Backside-Transport: OK OK
Connection: Keep-Alive
Transfer-Encoding: chunked
Server: nginx/1.11.1
Date: Sat, 25 Feb 2017 18:21:15 GMT
Content-Type: application/json
Access-Control-Allow-Origin: *
Access-Control-Allow-Headers: Authorization, Content-Type
X-Global-Transaction-ID: 339698429
Set-Cookie: DPJSESSIONID=PBC5YS:1376290542; Path=/; Domain=.whisk.ng.bluemix.net

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


## OpenWhisk authorisation:

When you first start, you need to authorise your `wsk` command with OpenWhisk:

    1. https://console.ng.bluemix.net/openwhisk/learn/cli
    2. Copy "New Authentication" command and paste into console
    3. Unset namespace: `wsk property unset --namespace`

