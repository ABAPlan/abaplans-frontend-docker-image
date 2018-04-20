FROM httpd:2.4

COPY ./frontend-dist/ /usr/local/apache2/htdocs/
COPY ./httpd.conf /usr/local/apache2/conf/httpd.conf
COPY ./certs/* /usr/local/apache2/conf/

EXPOSE 80 443