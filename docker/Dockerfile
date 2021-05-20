FROM alpine:3.12.0

RUN apk add --no-cache curl 

WORKDIR /home/terrascan

RUN mkdir bin

COPY argocd-terrascan-remote-scan.sh  bin/terrascan-remote-scan.sh

RUN addgroup --gid 101 terrascan && \
  adduser -S --uid 101 --ingroup terrascan terrascan && \
  chown -R terrascan:terrascan bin && \
  chmod u+x bin/terrascan-remote-scan.sh

USER 101

CMD ["sh"]