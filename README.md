docker-cookbook
===============

Chef cookbook for docker

Only tested on Ubuntu 12.04

This cookbook only supports x86\_64, since that appears to be the only platform on which docker is available for now.

The cookbook does its best to install the packages necessary to enable the `aufs` kernel module. Some kernels include it in the base kernel image, others require the `linux-image-extra` package. If the `aufs` module is not available, the cookbook will try to install the version of this package that matches the current kernel, as indicated by `ohai` attributes.

On certain ec2 images, the install fails while installing the `libsqlite3-dev` dependency. An `apt-get update` fixes this issue. A way to address this without leaking package manager updates into this cookbook itself is to include the `apt` cookbook in the `run_list` before this cookbook. (see the `Cheffile` and `Vagrantfile` [here](https://github.com/thoward/docker-vagrant) for an example)
