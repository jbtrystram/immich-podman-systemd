# immich-app podman + quadlet deployment

⚠️ **Currently supported immich version: [v2.5.2](https://github.com/immich-app/immich/releases/tag/v2.5.2)** ⚠️


This is a set of unit files to deploy immich through the podman-quadlet systemd generator

See the [podman documentation](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html) for details about podman quadlets.

This is adapted from the immich docker-compose file, this will create a podman pod hosting all the containers.

# Overview

The repo is organized into the following directories:

- **`quadlet/`**: Contains the core Quadlet unit files for deploying Immich services (database, server, machine learning, Redis) as Podman containers within a pod.
- **`hw-machine-learning/`**: Contains Quadlet unit files for hardware-accelerated machine learning configurations: OpenVINO and NVIDIA/AMD setups.
- **`kube/`**: Contains Kubernetes-style configuration files, including a ConfigMap and a Pod definition, for deploying Immich in a Kubernetes environment (or with podman kube play).
- **`backup/`**: Provides systemd service and timer units for regularly backing up the Immich PostgreSQL database. This is optionnal as [immich now provide a built-in service](https://docs.immich.app/administration/backup-and-restore/)

# How to Deploy

You may need to update the values in `quadlet/immich.env`.

## Database secret
Create a podman secret for the database password:

```
openssl rand -base64 20 | podman secret create immich-db-password -
```

## Volume setup

Since the update to 1.128.0 i changed how the volumes are declared. I was tired of having to copy-paste 
the quadlet files but having to update my volume paths each time.

See the [quadlet README](/quadlet/README.md#drop-ins) for details.

## rootful podman

You can simply copy or symlink the content of the `quadlet` folder:
`cp quadlet/* /etc/containers/systemd/`, then reload systemd. 

It can be a subdirectory. e.g : 
```
sudo cp -r quadlet /etc/containers/systemd/immich
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
sudo -u immich cp -v -r *.container *.pod immich.env *healthcheck volumes-dropins/* ~immich/.config/containers/systemd/immich/
```
Alternatively, quadlets can be placed under `/etc/containers/systemd/users/$(UID)`. See [documentation](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html#podman-rootless-unit-search-path).

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

# Kubernetes Deployment

For deploying Immich in a Kubernetes environment, refer to the documentation in [`kube/README.md`](./kube/README.md).

# Database Backup

To set up regular database backups, refer to the documentation in [`backup/README.md`](./backup/README.md).
Note that immich already have a database backup mechanism integrated, that have been added since I wrote this.

