Spec parameters for this operator:

```splunkHecHost``` - Splunk HEC hostname 

```splunkHecProtocol``` - using protocol, *https* - by default

```splunkPort``` - HEC listener port number - 8080 by default 

```logsIndex``` - Logs index name 

```objectIndex``` - Cluster objects index name 


```clusterName``` - REQUIRED parameters for define current cluster name, doesn't have default value to avoid messages overlapping .  


For define SplunkConnect instance:

```$xslt

apiVersion: logging.ocp.io/v1
kind: SplunkConnect
metadata:
  name: example-splunkconnect
spec:
  splunkHecHost: splunk.consto
  splunkPort: 9080
  clusterName:  ocp-dev
``` 