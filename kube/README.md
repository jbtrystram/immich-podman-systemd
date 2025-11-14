# Kube single-pod deployment

## SELinux
On SELinux-enabled systems, the context of mapped host directories needs to be set manually. If all the mapped directories are under `/path/to/immich`, set the context with
```
chcon -R -t container_file_t /path/to/immich
```

## rootful

Copy the contents of the `kube/` directory to `/etc/containers/systemd/`
or a subdirectory within, e.g. `/etc/containers/systemd/immich/`

Edit the environment variables in `immich-configMap.yaml` according to the Immich upstream docker-compose instructions and change the published port in `immich.kube`. Edit host directory mappings in `immich-pod.yaml`

Reload systemd units and start the service:
```
systemctl daemon-reload`
systemctl start immich
```

## rootless

Create and configure the user like above, username is `immich` in this example. Copy the contents of `kube/` to `~/.config/containers/systemd/` or a subdirectory within.

Edit `immich-configMap.yaml`, `immich-pod.yaml` and `immich.kube` like with the rootful deployment.

Change ownership of the host directories to the created user. This user's UID will be mapped as root inside the containers.

Start the user session, and the pod:
```
systemctl start user@$(id -u immich)`
systemctl --user -M immich@.host start immich.service
```