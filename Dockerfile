FROM maven:3-jdk-8

MAINTAINER Go About <tech@goabout.com>

ENV JAVA_MX=1G

RUN apt-get -yqq update && \
    apt-get -yq install s3cmd xzip &&\
    mkdir /tmp/build && \
    cd /tmp/build && \
    wget --progress dot:mega "https://s3.amazonaws.com/maven.conveyal.com/org/opentripplanner/otp/1.0.0/otp-1.0.0-shaded.jar" && \
    mkdir -p /usr/local/share/java && \
    mv otp-*shaded.jar /usr/local/share/java/otp.jar && \
    rm -r /tmp/build

COPY otp /usr/local/bin/
COPY files/s3cfg /opt/.s3cfg
COPY files/start_combined.sh /opt/start_combined.sh
COPY files/files.exclude /opt/files.exclude

RUN chmod 755 /usr/local/bin/*
RUN chmod 755 /opt/start_combined.sh

# Folders for s3cmd optionations
RUN mkdir /opt/src
RUN mkdir /opt/dest

EXPOSE 8080

ENTRYPOINT /opt/start_combined.sh
