FROM opendevstackorg/ods-jenkins-agent-base-ubi8:4.x

# Labels consumed by Red Hat build service
LABEL base.name="opendevstackorg/ods-jenkins-agent-base-ubi8:4.x" \
    description="The Jenkins Agent Node.js image has the Node.js and npm tools on top of the ODS Jenkins Agent Base Image." \
    io.k8s.display-name="Jenkins Agent Node.js" \
    io.openshift.tags="openshift,jenkins,agent,nodejs" \
    maintainer="Simon Golms <development@gol.ms>" \
    name="ods-jenkins-agent-nodejs-ubi8" \
    release="1" \
    summary="Provides the latest release of Jenkins Agent Node.js Universal Base Image 8." \
    version="1.0.0"

ARG NEXUS_AUTH
ARG NEXUS_URL
ARG NODEJS_VERSION
ARG NPM_VERSION

ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    NPM_CONFIG_PREFIX=$HOME/.npm-global \
    PATH=$HOME/node_modules/.bin/:$HOME/.npm-global/bin/:$PATH

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
