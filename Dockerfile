FROM dtzar/helm-kubectl 

WORKDIR /root

COPY ademo ./ademo/
COPY entrypoint.sh ./entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]
