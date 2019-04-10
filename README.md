
# mini-cluster
minikube-based cluster deployment

## Start minikube
```console
minikube start
```

## Include addons
```console
minikube addons enable metrics-server
```

## Build image
```console
docker build . -t harirakr/ademo-dock:v1
```

## Non-root users on host system
Edit ~/.kube/config in host.  
Set the `certificate-authority` and `client-certificate` paths to `/root/.minikube`

## Run image
```console
docker run \
    -v ~/.minikube:/root/.minikube \
    -v ~/.kube:/root/.kube \
    --add-host=kubernetes:<minikube-ip> \
    harirakr/ademo-dock:v1 init d0x2f/http-hello-world:v1.0.0
```

## Upgrade application
```console
docker run \
    -v ~/.minikube:/root/.minikube \
    -v ~/.kube:/root/.kube \
    --add-host=kubernetes:<minikube-ip> \
    harirakr/ademo-dock:v1 upgrade d0x2f/http-hello-world:v2.0.0
```

## Check for service reachability
### After deployment
```console
curl "$(minikube ip)":30101
Hello, world.
```
### After upgrade
```console
curl "$(minikube ip)":30101
Hello, world!
```
