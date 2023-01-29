FROM centos:7
# Install dependencies
RUN yum update -y && \
    yum install -y httpd && \
    yum search wget && \
    yum install wget -y && \
    yum install unzip -y

# change directory
RUN cd /var/www/html

# download webfiles
RUN wget https://www.free-css.com/assets/files/free-css-templates/download/page287/eflyer.zip

# unzip folder
RUN unzip eflyer.zip

# copy files into html directory
RUN cp -r eflyer/* /var/www/html/

# remove unwanted folder
RUN rm -rf eflyer eflyer.zip

# exposes port 80 on the container
EXPOSE 80

# set the default application that will start when the container start
ENTRYPOINT ["/usr/sbin/httpd", "-D", "FOREGROUND"]


