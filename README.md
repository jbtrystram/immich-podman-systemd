# immich-app podman + quadlet deployment

This is a set of unit files to deploy immich through the podman-quadlet systemd generator

See the [documentation](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html)
This is adapted from immich provided docker-compose file, this will create a podman pod hosting all thc containers.

# Overview

This setup consist in one `.image` file that does some prep work: pulling the image and creating a podman pod that will host all the containers
Then the `.container` files are translated into systemd units that create the containers. 

Note how the `immich-server.container` have an install target on `default.target` which makes it start on boot. 
I am not sure the `multi-user` target is really needed. 

# How do I deploy it ? 

Copy theses files into `/etc/containers/systemd` then reload systemd. 

It can be a subdirectory. e.g : 
```
sudo cp -r . /etc/containers/systemd/immich
sudo systemctl daemon-reload
```


# TODO 
- Delete the pod workaround once podman 5 is available (should be very soon)
- write a makefile or a justfile that insert the variables in the unit files maybe ? Right now it requires some copy and pasting.
- Contribute it upstream to immich (mainly waiting on podman 5)
