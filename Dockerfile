FROM dtzar/helm-kubectl 

WORKDIR /root

COPY ademo /root/ademo/
COPY entrypoint.sh /root/entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]
