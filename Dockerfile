FROM openjdk:8-jdk-alpine
MAINTAINER Xetus OSS <xetusoss@xetus.com>

# Add the archiva user and group with a specific UID/GUI to ensure
RUN addgroup --gid 1000 archiva &&\
	adduser --system -u 1000 -G archiva archiva &&\
	apk add bash curl

# Set archiva-base as the root directory we will symlink out of.
ENV ARCHIVA_HOME /archiva
ENV ARCHIVA_BASE /archiva-data
ARG BUILD_SNAPSHOT_RELEASE
ENV JVM_EXTRA_OPTS -Xms256m -Xmx500m -Djetty.http.port=$PORT -Dserver.port=$PORT -Djetty.port=$PORT 
# Add local scripts
ADD files /tmp

# Perform most initialization actions in this layer
RUN chmod +x /tmp/resource-retriever.sh &&\
	/tmp/resource-retriever.sh &&\
	rm /tmp/resource-retriever.sh &&\
	chmod +x /tmp/setup.sh &&\
	/tmp/setup.sh &&\
	rm /tmp/setup.sh

# Standard web ports exposted
#ENV PORT 8080
#RUN echo defaultport:$PORT
#EXPOSE $PORT/tcp # used in heroku
#EXPOSE 8080/tcp # used in local testing

CMD gunicorn --bind 0.0.0.0:$PORT wsgi

HEALTHCHECK CMD /healthcheck.sh

# Switch to the archiva user
USER archiva

# The volume for archiva
VOLUME /archiva-data

# Use SIGINT for stopping
STOPSIGNAL SIGINT

# Use our custom entrypoint
ENTRYPOINT [ "/entrypoint.sh" ]

