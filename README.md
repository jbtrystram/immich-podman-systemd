# immich-app podman + quadlet deployment

⚠️ **Curently supported immich version: [v1.108.0](https://github.com/immich-app/immich/releases/tag/v1.108.0)** ⚠️


This is a set of unit files to deploy immich through the podman-quadlet systemd generator

See the [documentation](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html)
This is adapted from immich provided docker-compose file, this will create a podman pod hosting all thc containers.

# Overview

This setup consist in:
 - `immich.pod` file defining a pod that will host all the containers.
 - `immich-server.image` defining the immich version.
 - several `immich-*.container` files defining the containers, volumes etc..
 - Systemd activation socket, `immich-proxy.socket`, this provides a way to access immich from
   outside the pod. Otherwise all the containers in this setup have no network access.
 
The `.container` files are translated into systemd units that create the containers. 

Note how the `immich-server.container` have an install target on `default.target` which makes it start on boot. 

# How do I deploy it ?

Rename `env.example` to `immich.env`. Populate the values as needed.

## rootful podman

Copy theses files into `/etc/containers/systemd` then reload systemd. Copy the .socket file to
`/etc/systemd/system`.

It can be a subdirectory. e.g : 
```
sudo cp -r . /etc/containers/systemd/immich
sudo cp immich-proxy.socket /etc/systemd/system
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
cat >> /etc/subuid <<EOF
immich:2000000:1000000
EOF

cat >> /etc/subgid <<EOF
immich:2000000:1000000
EOF
```

Copy immich-proxy.socket to `~immich/.config/systemd/user`.

Copy the remaining files into the user's `containers/systemd` directory:

```
sudo -u immich mkdir -p ~immich/.config/containers/systemd/immich
sudo -u immich cp -v *.image *.container *.pod immich.env ~immich/.config/containers/systemd/immich/
sudo -u immich mkdir -p ~immich/.config/systemd/user
sudo -u immich cp -v *.image *.socket ~immich/.config/systemd/user/
```

Start the user session, make it persistent and start the pod:
```
systemctl start user@$(id -u immich)
loginctl enable-linger immich
systemctl --user -M immich@.host start immich-pod.service
```

Watch `journalctl` to see if the containers start successfully -
the first start can fail if downloading the images takes more than the default startup timeout:
```
journalctl -f
```

The containers should start on the next boot automatically.


# Database backup

The `database_backup` folder suggests a way to dump the database regularly. Make sure to add a volume mount to the 
database container and bind it to `/var/db_backup`

As is, the unit will create gziped SQL dumps named with the date of creation: `YYYYMMDD`.

To enable it, place the files in `/etc/systemd/system` then enable the timer: `systemctl enable --now immich-database-backup.timer`.

# TODO 
- write a makefile or a justfile that insert the variables in the unit files maybe ? Right now it requires some copy and pasting.
- Contribute it upstream to immich : no longer a goal, they stated they are [not interested](https://github.com/immich-app/immich/discussions/7977).
