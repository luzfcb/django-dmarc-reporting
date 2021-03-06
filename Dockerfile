# Stage 1: frontend
FROM node:12.4-alpine as node
ADD . /app
WORKDIR /app
RUN yarn install \
    && yarn build \
    && rm -rf node_modules

# Stage 2: final image
FROM alpine:3.11
LABEL maintainer="VirtualTam"

RUN apk --update --no-cache add \
    ca-certificates \
    nginx \
    python3 \
    s6 \
    sqlite

ADD deploy/nginx.conf /etc/nginx/nginx.conf
ADD deploy/services.d /etc/services.d

COPY --from=node /app /app
WORKDIR /app
RUN pip3 install -r deploy/requirements.txt

RUN adduser -D -h /var/lib/app app \
    && mkdir -p /var/lib/app/db \
    && chown -R app:app /app /var/lib/app

VOLUME /var/lib/app/db

EXPOSE 80

CMD ["/app/deploy/entrypoint.sh"]
