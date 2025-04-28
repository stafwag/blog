---
layout: post
title: "docker-stafwag-hello_nginx v1.0.0 released"
date: 2025-04-27 08:08 +0100
comments: true
categories: [ "docker", "podman", "linux", "kubernetes", "helm", "redhat", "openshift" ] 
excerpt_separator: <!--more-->
---

<a href="{{ '/images/openshift/OpenShift-LogoType.svg' | remove_first:'/' | absolute_url }}"><img src="{{ '/images/openshift/OpenShift-LogoType.svg' | remove_first:'/' | absolute_url }}" class="right" width="400" height="427" alt="2025" /> </a>

While the code ( if you call [YAML](https://en.wikipedia.org/wiki/YAML) "code" ) is already more than 5 years old.
I finally took the take the make a proper release of my test "hello" [OCI](https://opencontainers.org) container.

I use this container to demo a container build and how to deploy it with helm on a Kubernetes cluster. Some test tools (ping, DNS, curl, wget) are included to execute some tests on the deployed pod.

It also includes a [Makefile](https://en.wikipedia.org/wiki/Make_(software)#Makefile) to build the container and deploy it on a
[Red Hat OpenShift Local (formerly Red Hat CodeReady Containers)](https://developers.redhat.com/products/openshift-local/overview]) cluster. 

To deploy the container with the included helm charts to OpenShift local (Code Ready Containers), execute make ```crc_deploy```.

This will:

1. Build the container image
2. Login to the internal OpenShift registry
3. Push the image to the internal OpenShift register
4. Deploy the helm chart in the tsthelm namespace, the helm chart will also create a route for the application.

I might include support for other [Kubernetes](https://en.wikipedia.org/wiki/Kubernetes) in the future when I find the time.

<!--more-->

docker-stafwag-hello_nginx v1.0.0 is available at:

[https://github.com/stafwag/docker-stafwag-hello_nginx](https://github.com/stafwag/docker-stafwag-hello_nginx)

# ChangeLog

## v1.0.0 Initial stable release

* Included dns utilities and documentation update by @stafwag in #3
* Updated Run section by @stafwag in #4

***Have fun!***
