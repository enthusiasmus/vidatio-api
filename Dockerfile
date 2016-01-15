FROM mhart/alpine-node:4.2.1
MAINTAINER Christian Lehner <lehner.chri@gmail.com>, Lukas Wanko <lwanko.mmt-m2014@fh-salzburg.ac.at>

RUN apk update && \
    apk upgrade && \
    apk add nginx git python make g++

WORKDIR /var/www/

# add package.json before copying the entire app to use caching
ADD package.json /var/www/

# needed for npm github installations
RUN git config --global url."https://".insteadOf git://

RUN npm install
RUN npm install -g gulp

ADD . /var/www/

EXPOSE 3000

CMD ["gulp", "production"]
