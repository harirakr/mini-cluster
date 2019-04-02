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
docker build . -t candidate-image
```

## Run image
```console
docker run \
    -v ~/.minikube:/root/.minikube \
    --add-host=kubernetes:<minikube-ip> \
    candidate-image init d0x2f/http-hello-world:v1.0.0
```

## Upgrade application
```console
docker run \
    -v ~/.minikube:/root/.minikube \
    --add-host=kubernetes:<minikube-ip> \
    candidate-image upgrade d0x2f/http-hello-world:v2.0.0
```

## Check for service reachability
### After deployment
```console
curl minikube:30101
Hello, world.
```
### After upgrade
```console
$ curl minikube:30101
Hello, world!
```
