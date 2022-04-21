FROM nginx:latest
#COPY ./nginx.conf /etc/nginx/conf.d/default.conf
COPY ./nginx.conf.template /etc/nginx/conf.d/default.conf.template
COPY ./index.html /usr/share/nginx/html/index.html
COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
EXPOSE 80
