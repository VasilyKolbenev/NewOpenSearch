# syntax=docker/dockerfile:1.7-labs


FROM bellsoft/liberica-openjdk-centos:21
# FROM bellsoft/liberica-openjdk-debian:21

ARG UID=1000
ARG GID=1000
ARG OPENSEARCH_HOME=/usr/share/opensearch


RUN yum update -y && yum install -y tar gzip shadow-utils which && yum clean all

# Create an opensearch user, group
RUN groupadd -g $GID opensearch && \
adduser -u $UID -g $GID -d $OPENSEARCH_HOME opensearch

# Copy from Stage0
# COPY --from=linux_stage_0 --chown=$UID:$GID $OPENSEARCH_HOME $OPENSEARCH_HOME
# COPY --from=opensearchproject/opensearch:2.14.0 --exclude=jdk --chown=$UID:$GID $OPENSEARCH_HOME $OPENSEARCH_HOME
COPY --from=opensearchproject/opensearch:1 --exclude=jdk --chown=$UID:$GID $OPENSEARCH_HOME $OPENSEARCH_HOME


WORKDIR $OPENSEARCH_HOME

# # Set $JAVA_HOME
# RUN echo "export JAVA_HOME=$OPENSEARCH_HOME/jdk" >> /etc/profile.d/java_home.sh && \
#     echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> /etc/profile.d/java_home.sh
# ENV JAVA_HOME=$OPENSEARCH_HOME/jdk
# ENV PATH=$PATH:$JAVA_HOME/bin:$OPENSEARCH_HOME/bin
ENV PATH=$PATH:$OPENSEARCH_HOME/bin


# Add k-NN lib directory to library loading path variable
ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$OPENSEARCH_HOME/plugins/opensearch-knn/lib"

# Change user
USER $UID


# Setup OpenSearch
# Disable security demo installation during image build, and allow user to disable during startup of the container
# Enable security plugin during image build, and allow user to disable during startup of the container
ARG DISABLE_INSTALL_DEMO_CONFIG=true
ARG DISABLE_SECURITY_PLUGIN=false
RUN ./opensearch-onetime-setup.sh

EXPOSE 9200 9300 9600 9650


# CMD to run
ENTRYPOINT ["./opensearch-docker-entrypoint.sh"]
CMD ["opensearch"]