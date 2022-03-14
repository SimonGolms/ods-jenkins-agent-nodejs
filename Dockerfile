FROM opendevstackorg/ods-jenkins-agent-base-ubi8:4.x

# Labels consumed by Red Hat build service
LABEL com.redhat.component="jenkins-agent-nodejs-ubi8-docker" \
    base.name="opendevstackorg/ods-jenkins-agent-base-ubi8:4.x" \
    maintainer="Simon Golms <development@gol.ms>" \
    name="openshift/jenkins-agent-nodejs-ubi8" \
    description="The jenkins agent nodejs image has the nodejs tools on top of the jenkins agent base image." \
    version="1.0.0" \
    io.k8s.display-name="Jenkins Agent NodeJs" \
    io.openshift.tags="openshift,jenkins,agent,nodejs"

ARG NEXUS_AUTH
ARG NEXUS_URL
ARG NODEJS_VERSION
ARG NPM_VERSION

ENV NPM_CONFIG_PREFIX=$HOME/.npm-global \
    PATH=$HOME/node_modules/.bin/:$HOME/.npm-global/bin/:$PATH \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

# Build image with the latest (security) updates
RUN dnf -y update

# Install Node.js and npm
# https://github.com/nodesource/distributions#installation-instructions-1
RUN curl --silent --show-error --location https://rpm.nodesource.com/setup_${NODEJS_VERSION} | bash - && \
    dnf install -y nodejs && \
    if [ ! -z "$NPM_VERSION" ]; then npm install -g npm@${NPM_VERSION}; fi

# Configure npm
RUN if [ ! -z "$NEXUS_AUTH" ] && [ ! -z "$NEXUS_URL" ]; then \
    npm config set _auth=$(echo -n $NEXUS_AUTH | base64) && \
    npm config set always-auth=true && \
    npm config set registry=$NEXUS_URL/repository/npmjs/; \
    fi && \
    npm config set ca=null && \
    npm config set strict-ssl=false

# Verify installation
RUN echo node version: $(node --version) && \
    echo npm version: $(npm --version) && \
    echo npx version: $(npx --version)

# Clean dnf cache to reduce size
RUN dnf autoremove && dnf clean all

# Fix permissions
RUN chgrp -R 0 $HOME && \
    chmod -R g=u $HOME && \
    chmod g+w $JAVA_HOME/lib/security/cacerts

USER 1001
