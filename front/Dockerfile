FROM nginx:latest
COPY ./nginx.conf.template /nginx.conf.template
COPY ./index.html /usr/share/nginx/html/index.html
CMD ["/bin/sh" , "-c" , "envsubst < /nginx.conf.template > /etc/nginx/nginx.conf"]
EXPOSE 80
