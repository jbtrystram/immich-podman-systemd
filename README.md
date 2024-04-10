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

Rename `env.example` to `immich.env`.

## rootful podman

Copy theses files into `/etc/containers/systemd` then reload systemd. 

It can be a subdirectory. e.g : 
```
sudo cp -r . /etc/containers/systemd/immich
sudo systemctl daemon-reload
```

## rootless podman

Create a user that will run immich containers.
The containers will act as this user on the host:
- This user will be used when enforcing file permissions in the mounted volumes.
- When immich creates files in the mounted volumes, they will be owned by this user on the host.

```
useradd -r -m -d /var/lib/immich immich
```
The containers and named volumes will be stored in `/var/lib/immich`.

Configure `subuid` and `subgid` for podman to be able to run as this user:
```
# cat >> /etc/subuid <<EOF
immich:2000000:1000000
EOF
# cat >> /etc/subgid <<EOF
immich:2000000:1000000
EOF
```

Copy these files into the user's `containers/systemd` directory:
```
# sudo -u immich mkdir -p ~immich/.config/containers/systemd/immich
# sudo -u immich cp -v *.image *.container *.pod immich.env ~immich/.config/containers/systemd/immich/
```

Start the user session, make it persistent and start the pod (replace 998 with `immich` user ID):
```
# systemctl start user@998
# loginctl enable-linger immich
# systemctl --user -M immich@.host start immich-pod.service
```

Watch `journalctl` to see if the containers start successfully -
the first start can fail if downloading the images takes more than the default startup timeout:
```
# journalctl -f
```

The containers should start on the next boot automatically.


# TODO 
- write a makefile or a justfile that insert the variables in the unit files maybe ? Right now it requires some copy and pasting.
- Contribute it upstream to immich
