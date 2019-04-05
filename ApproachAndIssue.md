# Solution approach

## OPTION 1
Use a helm-kubectl container to build on.
Build a docker container with an entrypoint script to invoke a helm chart.
The helm chart will be configured to deploy pods, load-balancer, 
ingress (_not done yet_) and horizontalpodautoscaler.

### Issues: 
- 1. kubectl commands fail while running from within the docker container 
- 2. cannot access service as per command specified

On the console this works

```console 
minikube start
minikube addons enable metrics-server

./entrypoint.sh init harirakr/gohello:v1.0.0
./entrypoint.sh upgrade harirakr/gohello:v2.0.0

$ kubectl get service
NAME                   TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
auxiliary-newt-ademo   LoadBalancer   10.107.71.97   <pending>     8080:30101/TCP   24m
kubernetes             ClusterIP      10.96.0.1      <none>        443/TCP          128m
$ minikube service auxiliary-newt-ademo --url
http://192.168.99.109:30101
$ curl http://192.168.99.109:30101
Hello, world!
```
The autoscaling works based on target cpu utilization.

But from within my docker container, the kubectl commands to configure the 
serviceaccount with tiller fails. I am yet to figure out why.

Also, the service url has to be provided to access the service.
 



