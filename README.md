# OpenDevStack 4.x - Jenkins Agent Node.js

[![Version](https://img.shields.io/badge/version-2.1.0-blue.svg)](https://github.com/SimonGolms/ods-jenkins-agent-nodejs/releases)
[![License: Apache-2.0](https://img.shields.io/github/license/simongolms/ods-jenkins-agent-nodejs)](https://github.com/simongolms/ods-jenkins-agent-nodejs/blob/master/LICENSE)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://github.com/simongolms/ods-jenkins-agent-nodejs/graphs/commit-activity)
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-green.svg)](https://conventionalcommits.org)
[![semantic-release: angular](https://img.shields.io/badge/semantic--release-angular-e10079?logo=semantic-release)](https://github.com/semantic-release/semantic-release)
[![OpenDevStack](https://img.shields.io/badge/OpenDevStack-4.x-9e312a)](https://www.opendevstack.org/)
[![OpenShift Container Platform](https://img.shields.io/badge/OpenShift%20Container%20Platform-4.x-EE0000?logo=Red-Hat-Open-Shift)](https://docs.openshift.com/container-platform)
[![Jenkins Agent](https://img.shields.io/badge/Jenkins-Agent-d24939?logo=jenkins)](https://www.jenkins.io/)

## Introduction

This Jenkins agent is used to build Node.js based projects, thru `npm` and `npx`. It use `ods/jenkins-agent-base:4.x` as base image in an OpenShift 4 Instance with OpenDevStack 4.x.

### Features

1. Node.js `v16.x` | `v18.x` | `lts` | `current`
2. npm `v8.x` | `latest`
3. (optional) Nexus configuration

### Usage

The image is built in your active OpenShift Project and is named `jenkins-agent-nodejs-<VERSION>`.
It can be referenced in a `Jenkinsfile` with `<PROJECT>/jenkins-agent-nodejs-<VERSION>`.

```diff
// Jenkinsfile
odsComponentPipeline(
-  imageStreamTag: 'ods/jenkins-agent-nodejs12:4.x',
+  imageStreamTag: "foo-cd/jenkins-agent-nodejs-16:latest",
)
```

```diff
// Jenkinsfile with custom agent resources
odsComponentPipeline(
-  imageStreamTag: 'ods/jenkins-agent-nodejs12:4.x',
+  podContainers: [
+    containerTemplate(
+      alwaysPullImage: true,
+      args: '${computer.jnlpmac} ${computer.name}',
+      image: "image-registry.openshift-image-registry.svc:5000/foo-cd/jenkins-agent-nodejs-16:latest",
+      name: 'jnlp',
+      resourceLimitCpu: '3',
+      resourceLimitMemory: '8Gi',
+      resourceRequestCpu: '10m',
+      resourceRequestMemory: '4Gi',
+      workingDir: '/tmp'
+    )
+  ],
)
```

## Provisioning

### CLI

```sh
# v16.x
oc process -f https://raw.githubusercontent.com/SimonGolms/ods-jenkins-agent-nodejs/main/jenkins-agent-nodejs-16-template.yaml | oc create -f -
# v18.x
oc process -f https://raw.githubusercontent.com/SimonGolms/ods-jenkins-agent-nodejs/main/jenkins-agent-nodejs-18-template.yaml | oc create -f -
# lts
oc process -f https://raw.githubusercontent.com/SimonGolms/ods-jenkins-agent-nodejs/main/jenkins-agent-nodejs-lts-template.yaml | oc create -f -
# current
oc process -f https://raw.githubusercontent.com/SimonGolms/ods-jenkins-agent-nodejs/main/jenkins-agent-nodejs-current-template.yaml | oc create -f -
```

```sh
# with nexus configuration
oc process -f https://raw.githubusercontent.com/SimonGolms/ods-jenkins-agent-nodejs/main/jenkins-agent-nodejs-<VERSION>-template.yaml \
  -p NEXUS_URL=https://NEXUS_INSTANCE \
  -p NEXUS_AUTH=USERNAME:PASSWORD \
  | oc create -f -
```

### Manual

Import `jenkins-agent-nodejs-<VERSION>-template.yaml` into your OpenShift instance and process the template. Replace your project name if necessary (e.g. `foo-cd` -> `bar-cd`).

Go to <https://OPENSHIFT_INSTANCE/catalog/ns/PROJECT?catalogType=Template&keyword=jenkins> and click on `Jenkins Agent Node.js (<VERSION>)` -> `Instantiate Template` -> `Create`

## Update

### CLI

In case of a new version of Node.js or npm is released, run the following command to create a new image with updated versions:

```sh
# v16.x
oc start-build jenkins-agent-nodejs-16 --follow
# v18.x
oc start-build jenkins-agent-nodejs-18 --follow
# lts
oc start-build jenkins-agent-nodejs-lts --follow
# current
oc start-build jenkins-agent-nodejs-current --follow
```

In case it is necessary and you need a specific npm version, you can provide it via `--build-arg`:

```sh
# with specific npm version
oc start-build jenkins-agent-nodejs-<VERSION> --build-arg NPM_VERSION=8.5.3 --follow
```

### Manual

Go to your Build Configs <https://OPENSHIFT_INSTANCE/k8s/ns/PROJECT/buildconfigs/jenkins-agent-nodejs-VERSION> and click on `Actions` -> `Start Build`.

## Abandon

### CLI

```sh
# v16.x
oc delete all --selector app=jenkins-agent-nodejs-16
# v18.x
oc delete all --selector app=jenkins-agent-nodejs-18
# lts
oc delete all --selector app=jenkins-agent-nodejs-lts
# current
oc delete all --selector app=jenkins-agent-nodejs-current
# v16.x & v18.x & lts & current
oc delete all --selector part-of=jenkins-agent-nodejs
```

#### (Optional) Template from workspace catalog

```sh
oc delete template jenkins-agent-nodejs-<VERSION>
```

### Manual

1. Go to your Image Streams <https://OPENSHIFT_INSTANCE/k8s/ns/PROJECT/imagestreams/jenkins-agent-nodejs-VERSION> and click on `Actions` -> `Delete ImageStream`.
2. Go to your Build Configs <https://OPENSHIFT_INSTANCE/k8s/ns/PROJECT/buildconfigs/jenkins-agent-nodejs-VERSION> and click on `Actions` -> `Delete BuildConfig`.

## Author

**Simon Golms**

- Digital Card: `npx simongolms`
- Github: [@SimonGolms](https://github.com/SimonGolms)
- Website: [gol.ms](https://gol.ms)

## Show your support

Give a ⭐️ if this project helped you!

## License

Copyright © 2022 [Simon Golms](https://github.com/simongolms).<br />
This project is [Apache-2.0](https://github.com/simongolms/ods-jenkins-agent-nodejs/blob/master/LICENSE) licensed.

## Resources

- https://nodejs.org
- https://docs.openshift.com/container-platform/4.10/openshift_images/using-templates.html
- https://docs.openshift.com/container-platform/4.10/rest_api/template_apis/template-template-openshift-io-v1.html
- https://github.com/opendevstack/ods-core/blob/master/jenkins/agent-base/Dockerfile.ubi8
- https://github.com/opendevstack/ods-quickstarters/tree/master/common/jenkins-agents/nodejs12/docker
