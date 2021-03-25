# build environment
FROM nodejs14 as builder

# set working directory
#RUN mkdir /usr/src/app
WORKDIR /home/node

ENV PATH /home/node/node_modules/.bin:$PATH

COPY package.json /home/node/package.json
RUN npm install
RUN npm install @angular/cli@8.0.6 --unsafe

COPY . /home/node

RUN npm run build --output-path=dist

FROM apache2-hardened-fixed

# copy compiled app to server
COPY --from=builder /home/node/dist/hygieia-ui /var/www/html

COPY ./httpd/.htaccess /var/www/html/.htaccess

# copy startup script
COPY ./startup.sh /etc/httpd/startup.sh

# make script executable
USER root
RUN chown apache:apache /etc/httpd/startup.sh && chown -R apache:apache /var/www/html

RUN chmod +x /etc/httpd/startup.sh
USER apache
# expose port 80
EXPOSE 80

ENTRYPOINT ["/etc/httpd/startup.sh"]

CMD ["httpd" "-D", "FOREGROUND"]
