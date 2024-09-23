FROM debian

USER root
WORKDIR /root
COPY ./entrypoint.sh ./

RUN apt-get update &&\
    apt-get -y install openssh-server wget supervisor nginx unzip &&\
	apt-get clean

# Configure nginx
RUN wget -O doge.zip https://github.com/tholman/long-doge-challenge/archive/refs/heads/main.zip && \
    rm -rf /var/www/* && \
    unzip -d /var/www/ doge.zip && \
    rm doge.zip && \
    mv /var/www/* /var/www/html

RUN chmod +x /root/entrypoint.sh

ENV PASSWORD="123456"
ENV ARGO_AUTH=""
EXPOSE 80

ENTRYPOINT ["/bin/bash","/root/entrypoint.sh"]