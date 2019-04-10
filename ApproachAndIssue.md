# Solution approach

## FIRST ATTEMPT
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
 

## SECOND ATTEMPT 
After implementing the suggestions, the changes worked, albeit with a few assumptions.

### Assumptions on the problem
1. The minikube cluster is started by the `root` user in the host system.
2. The `docker build` command is run from `/root`. This would allow the 
   `/root/.kube` directory to be copied into the image using the Dockerfile. 
3. `minikube` resolves to the API server IP address in the host.

### As non-root user
1. The `~/.kube/config` file had to be manually edited to point to the path of the 
   minikube credentials within the docker container.
2. The `docker build` command is run in a sub-directory. Hence had to mount the 
   `~/.kube` directory during the `docker run` command.
3. In curl command, used `$(minikube ip)` to get the API server IP address.

### Shell script Issue
1. Shellshock identified four places in the code that could have resulted in globbing 
   and word-splitting issues - resolved.

