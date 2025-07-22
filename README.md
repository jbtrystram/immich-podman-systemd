# immich-app podman + quadlet deployment

⚠️ **Curently supported immich version: [v1.135.3](https://github.com/immich-app/immich/releases/tag/v1.135.3)** ⚠️


This is a set of unit files to deploy immich through the podman-quadlet systemd generator

See the [documentation](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html)
This is adapted from immich provided docker-compose file, this will create a podman pod hosting all thc containers.

# Overview

This setup consist in:
 - `immich.pod` file defining a pod that will host all the containers.
 - `immich-server.image` defining the immich version.
 - several `immich-*.container` files defining the containers, volumes etc..
 
The `.container` files are translated into systemd units that create the containers. 

Note how the `immich-server.container` have an install target on `default.target` which makes it start on boot. 

# How do I deploy it ?

Rename `env.example` to `immich.env`. Populate the values as needed.

## Volume setup

Since the update to 1.128.0 i changed how the volumes are declared. I was tired of having to copy-paste 
the quadlet files but having to update my volume paths each time.
So i created the [volume-dropins](./volume-dropins) folder where the volumes mounts can be defined
once and they will be merged with the final quadlet.


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
cat >> /etc/subuid <<EOF
immich:2000000:1000000
EOF

cat >> /etc/subgid <<EOF
immich:2000000:1000000
EOF
```

Copy these files into the user's `containers/systemd` directory:
```
sudo -u immich mkdir -p ~immich/.config/containers/systemd/immich
sudo -u immich cp -v -r *.image *.container *.pod immich.env *healthcheck volumes-dropins/* ~immich/.config/containers/systemd/immich/
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

# Alternative single-pod deployment

## SELinux
On SELinux-enabled systems, the context of mapped host directories needs to be set manually. If all the mapped directories are under `/path/to/immich`, set the context with
```
chcon -R -t container_file_t /path/to/immich
```

## rootful

Copy the contents of the `alternative/` directory to `/etc/containers/systemd/`
or a subdirectory within, e.g. `/etc/containers/systemd/immich/`

Edit the environment variables in `immich-configMap.yaml` according to the Immich upstream docker-compose instructions and change the published port in `immich.kube`. Edit host directory mappings in `immich-pod.yaml`

Reload systemd units and start the service:
```
systemctl daemon-reload`
systemctl start immich
```

## rootless

Create and configure the user like above, username is `immich` in this example. Copy the contents of `alternative/` to `~/.config/containers/systemd/` or a subdirectory within.

Edit `immich-configMap.yaml`, `immich-pod.yaml` and `immich.kube` like with the rootful deployment.

Change ownership of the host directories to the created user. This user's UID will be mapped as root inside the containers.

Start the user session, and the pod:
```
systemctl start user@$(id -u immich)`
systemctl --user -M immich@.host start immich.service
```



# Database backup

The `database_backup` folder suggests a way to dump the database regularly. Make sure to add a volume mount to the 
database container and bind it to `/var/db_backup`

As is, the unit will create gziped SQL dumps named with the date of creation: `YYYYMMDD`.

To enable it, place the files in `/etc/systemd/system` then enable the timer: `systemctl enable --now immich-database-backup.timer`.

