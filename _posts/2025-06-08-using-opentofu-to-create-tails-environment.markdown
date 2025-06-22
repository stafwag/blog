---
layout: post
title: "Using OpenTofu/Terraform to create a disposable Tails virtual machine"
date: 2025-06-22 07:37:00 +0100
comments: true
categories: [ tails, tor, linux, libvirt, opentofu, terraform, fosdem ]
excerpt_separator: <!--more-->
---

<a href="{{ '/images/opentofu/opentofu_square.png' | remove_first:'/' | absolute_url }}"><img src="{{ '/images/opentofu/opentofu_square.png' | remove_first:'/' | absolute_url }}" class="left" width="264" height="191" alt="OpenTofu" /> </a>

## OpenTofu

[Terraform](https://developer.hashicorp.com/terraform) or [OpenTofu](https://opentofu.org/) ( the open-source fork [supported by the Linux Foundation](https://www.linuxfoundation.org/press/announcing-opentofu) ) is a nice tool to setup the infrastructure
on different cloud environments. There is also a provider that supports [libvirt](https://libvirt.org/).

* [https://github.com/dmacvicar/terraform-provider-libvirt](https://github.com/dmacvicar/terraform-provider-libvirt)

If you want to get started with OpenTofu there is a free training available from the Linux foundation:

* [https://training.linuxfoundation.org/express-learning/getting-started-with-opentofu-lfel1009/](https://training.linuxfoundation.org/express-learning/getting-started-with-opentofu-lfel1009/)

I also joined the talk about OpenTofu and [Infrastructure As Code](https://en.wikipedia.org/wiki/Infrastructure_as_code), in general, this year in the [Virtualization and Cloud Infrastructure](https://fosdem.org/2025/schedule/track/virtualization/) DEV Room at [FOSDEM](https://fosdem.org) this year:

* [https://fosdem.org/2025/schedule/event/fosdem-2025-6057-the-iac-tooling-multiverse-and-the-future-of-iac/](https://fosdem.org/2025/schedule/event/fosdem-2025-6057-the-iac-tooling-multiverse-and-the-future-of-iac/)

<!--more-->

I'll not start to explain "Declarative" vs "Imperative" in this blog post, there're already enough blog posts or websites that're (trying) to explain this in more detail ( the links above are a good start).

The default behaviour of OpenTofu is not to try to update an existing environment. This makes it usable to create disposable environments.

<a href="{{ '/images/tails/tails_description.png' | remove_first:'/' | absolute_url }}"><img src="{{ '/images/tails/tails_description.png' | remove_first:'/' | absolute_url }}" class="right" width="320" height="135" alt="Tails description" /> </a>

## Tails

[Tails](https://tails.net/) is a nice GNU/Linux distribution to connect to the [Tor network](https://www.torproject.org/).

Personally, I'm less into the "privacy" aspect of the Tor network (although being aware that you're tracked and followed is important), probably because I'm lucky to live in the "Free world".

For people who are less lucky (People who live in a country where freedom of speech isn't valued) or journalists for example, there're good reasons to use the Tor network and hide their internet traffic.

## tails/libvirt Terraform/OpenTofu module

<a href="{{ '/images/tails/terraform-libvirt-tails.png' | remove_first:'/' | absolute_url }}"><img src="{{ '/images/tails/terraform-libvirt-tails.png' | remove_first:'/' | absolute_url }}" class="right" width="484" height="142" alt="OpenTofu" /> </a>

To make it easier to spin up a virtual machine with the latest tail environment I created a Terraform/OpenTofu module to spin up a virtual machine with the latest Tails version on
libvirt.

There're security considerations when you run tails in a virtual machine.
See

* [https://tails.net/doc/advanced_topics/virtualization/index.en.html](https://tails.net/doc/advanced_topics/virtualization/index.en.html)

for more information.

The source code of the module is available at the git repository:

* [https://github.com/stafwag/terraform-libvirt-tails](https://github.com/stafwag/terraform-libvirt-tails)

The module is published on the [Terraform Registry](https://registry.terraform.io/) and
the [OpenTofu Registry](https://opentofu.org/registry/).

***Have fun!***
