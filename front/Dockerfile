FROM nginx:latest
#COPY ./nginx.conf /etc/nginx/conf.d/default.conf
#COPY ./nginx.conf /nginx.conf
RUN envsubst < nginx.conf > /etc/nginx/default.conf
COPY ./index.html /usr/share/nginx/html/index.html
EXPOSE 80
