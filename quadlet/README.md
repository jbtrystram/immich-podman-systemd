# Base quadlets 

This folder consists of:
 - `immich.pod` file defining a pod that will group all the containers : see the podman documentation for more details.
 - `immich-server.image` defining the immich version. This will pre-pull the server image so it's available on the system before the container start.
 - several `immich-*.container` files defining the containers, volumes etc..
 
The `.container` files are translated into systemd units that create the containers. See [podman documentation](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html).

Note how the `immich-server.container` has an install target on `default.target` which makes it start on boot.

# Drop-ins

The volumes are defined through drop-ins so you can have your own set of volumes mounts, without altering the git-defined quadlets.
Rename the files without the `.example` suffix and edit the volumes mounts appropriately.
Simply copy those folders at the same place your quadlets files live, rootful or rootless. Make sure the folder name matches the unit with a `.d` suffix.

See the drop-ins paragraph in the [documentation](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html#description) for more.

Note : drop-ins files should be excluded through gitignore to make it easier to just use this repo as-is.

# Machine learning

As-is, no machine learning container will be started, as the `immich-machine-learning.container` is not pulled in the dependency chain.
This is intentional, so you can pick whichever quadlet definition suits your hardware. See [../hw-machine-learning/README.md] for more explanation.
