ARG BUILD_REGISTRY=registry1.dso.mil
ARG BUILD_IMAGE=ironbank/opensource/nodejs/nodejs14
ARG BUILD_TAG=latest
ARG BASE_REGISTRY=registry.il2.dso.mil
ARG BASE_IMAGE=platform-one/devops/pipeline-templates/base-image/harden-nginx-19
ARG BASE_TAG=1.19.6
# our base build image
FROM ${BUILD_REGISTRY}/${BUILD_IMAGE}:${BUILD_TAG} as builder

# set working directory
#RUN mkdir /usr/src/app
WORKDIR /home/node

ENV PATH /home/node/node_modules/.bin:$PATH

COPY package.json /home/node/package.json
RUN npm install
RUN npm install @angular/cli@8.0.6 --unsafe

COPY . /home/node

RUN npm run build --output-path=dist

FROM ${BASE_REGISTRY}/${BASE_IMAGE}:${BASE_TAG}

# copy compiled app to server
COPY --from=builder /home/node/dist/hygieia-ui /var/www/

USER root

#COPY --chown=appuser nginx-proxy.conf /etc/nginx/

RUN sed -i -e s/location/location\ \\/api\\/\ \{\ proxy_pass\ http\:\\/\\/api\:8080\\/api\\/\;\ \}\\n\\rlocation/ /etc/nginx/nginx.conf

USER appuser

COPY ./httpd/.htaccess /var/www/.htaccess