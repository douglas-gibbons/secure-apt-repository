FROM ubuntu

RUN apt-get update && apt-get -y install reprepro apache2 && apt-get clean
RUN rm /var/www/html/index.html

COPY entrypoint.sh /entrypoint.sh
COPY update.sh /update.sh

RUN chmod +x /entrypoint.sh
RUN chmod +x /update.sh

EXPOSE 80

CMD /entrypoint.sh



