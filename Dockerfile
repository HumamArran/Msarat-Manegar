FROM ubuntu:12.04
RUN sed -i -e 's/archive.ubuntu.com\|security.ubuntu.com/old-releases.ubuntu.com/g' /etc/apt/sources.list
RUN apt-get -y update && apt-get -y upgrade
RUN apt-get -y install nano inotify-tools libc6:i386 iputils-ping apache2 apache2-doc apache2-utils unzip mc wget rcconf make gcc libperl-dev curl php5 php5-cli php5-curl php5-mcrypt php5-gd php5-snmp
RUN apt-get clean && apt-get -f autoremove -y
#RUN cd /home/dma-freerad-files
#we need to run this bash script below, its in /home/dma-freerad-files
#RUN bash nullglob.sh
RUN cd /var/lib/apt/lists && rm -rf *
RUN mkdir -p partial && apt-get clean && apt-get -y dist-upgrade && apt-get -y update && ldconfig
RUN apt-get -y install mysql-server libmysqlclient15-dev php5-mysql
#RUN cd /home && chmod +x mysql_setup.sh
#RUN cd /home && bash mysql_setup.sh
COPY /files/* /home/
WORKDIR /home
RUN dpkg -i libltdl3_1.5.26-1ubuntu1_amd64.deb && sleep 3s && dpkg -i libltdl3-dev_1.5.26-1ubuntu1_amd64.deb && ldconfig && rm libltdl3_1.5.26-1ubuntu1_amd64.deb && rm libltdl3-dev_1.5.26-1ubuntu1_amd64.deb
RUN unzip ioncube_loaders_lin_x86-64-5.3.zip && sleep 5s && cp -r /home/ioncube/ /usr/local/ && ldconfig && echo "zend_extension=/usr/local/ioncube/ioncube_loader_lin_5.3.so" >> /etc/php5/apache2/php.ini && echo "zend_extension=/usr/local/ioncube/ioncube_loader_lin_5.3.so" >> /etc/php5/cli/php.ini && ldconfig && rm -rf ioncube && rm ioncube_loaders_lin_x86-64-5.3.zip
RUN unzip freeradius-server-2.2.0.zip && cd freeradius-server-2.2.0 && chmod +x configure && chmod +x install-sh && ./configure && make && make install && cd ~ && chown www-data /usr/local/etc/raddb && chown www-data /usr/local/etc/raddb/clients.conf && ldconfig

WORKDIR /etc
RUN mv rc.local rc.local.old && > rc.local && echo "#created By Abdulkader and edited by MaGeek to Fix Radius Runing & Apache2 Servers" >> rc.local && echo "echo ---++++ TechnoMeem ++++--- && echo System Restart Server apache2 && sleep 10s && service radiusd restart && sleep 5s && service apache2 restart && sleep 10s && echo ... OK ! Config By MaGeek && sleep 5s" >> rc.local && echo "exit 0" >> rc.local && sleep 3s && chown root.root /etc/rc.local && chmod 777 /etc/rc.local && echo "ServerName localhost" >> /etc/apache2/apache2.conf && sleep 3s && ldconfig && sleep 3s && chown root.root /etc/rc.local && cd ~
WORKDIR /home
#RUN chmod 644 ./crons && cp ./crons /etc/cron.d/
RUN chmod +x ./init_container.sh

# CMD ["bash","init_container.sh"]

#ENTRYPOINT ["service","apache2","restart"] 
#RUN cd /home && cp sql.conf /usr/local/etc/raddb/
#now create dma bridge network on using: docker network create --driver=bridge  dma

# RUN tar -xvf radiusmanager-4.1.6.gz &&  cd radiusmanager-4.1.6 && bash install.sh
# docker run --name mysql -d -p 3306:3306 --network host -e MYSQL_ROOT_PASSWORD=123456 -v mysql:/var/lib/mysql mysql:5
# docker run --name mysql -d --network host -e MYSQL_ROOT_PASSWORD=123456 -v mysql:/var/lib/mysql mysql:5
