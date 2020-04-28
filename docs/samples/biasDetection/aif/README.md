# Bias detection on a InferenceService using aif360

## Create the InferenceService

Apply the CRD

```
kubectl apply -f bias.yaml
```

Expected Output

```
$ inferenceservice.serving.kubeflow.org/german-credit created
```

### Run a prediction

Use `kfserving-ingressgateway` as your `INGRESS_GATEWAY` if you are deploying KFServing as part of Kubeflow install, and not independently.

```
MODEL_NAME=german-credit
INPUT_PATH=@./input.json
INGRESS_GATEWAY=istio-ingressgateway
CLUSTER_IP=$(kubectl -n istio-system get service $INGRESS_GATEWAY -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
SERVICE_HOSTNAME=$(kubectl get inferenceservice ${MODEL_NAME} -o jsonpath='{.status.url}' | cut -d "/" -f 3)

curl -v -H "Host: ${SERVICE_HOSTNAME}" http://${CLUSTER_IP}/v1/models/${MODEL_NAME}:predict -d $INPUT_PATH
```

### Run a bias detection

```
curl -v -H "Host: ${SERVICE_HOSTNAME}" http://${CLUSTER_IP}/v1/models/${MODEL_NAME}:biasDetector -d $INPUT_PATH
```

### Expected output

```
curl -v -H "Host: ${SERVICE_HOSTNAME}" http://${CLUSTER_IP}/v1/models/${MODEL_NAME}:biasDetector -d $INPUT_PATH
*   Trying 169.46.78.211...
* TCP_NODELAY set
* Connected to 169.46.78.211 (169.46.78.211) port 80 (#0)
> POST /v1/models/german-credit:biasDetector HTTP/1.1
> Host: german-credit-default.os-js-442dbba0442be6c8c50f31ed96b00601-0000.us-south.containers.appdomain.cloud
> User-Agent: curl/7.64.1
> Accept: */*
> Content-Length: 4700
> Content-Type: application/x-www-form-urlencoded
> Expect: 100-continue
>
< HTTP/1.1 100 Continue
* We are completely uploaded and fine
< HTTP/1.1 200 OK
< content-length: 653
< content-type: application/json; charset=UTF-8
< date: Mon, 20 Apr 2020 18:28:22 GMT
< server: istio-envoy
< x-envoy-upstream-service-time: 70
<
* Connection #0 to host 169.46.78.211 left intact
{"predictions": [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 2.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 2.0, 1.0, 2.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 2.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 2.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 2.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0], "metrics": {"base_rate": 0.9230769230769231, "consistency": [0.9871794871794872], "disparate_impact": 0.45454545454545453, "num_instances": 78.0, "num_negatives": 6.0, "num_positives": 72.0, "statistical_parity_difference": -0.5454545454545454}}* Closing connection 0
```
