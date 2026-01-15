# Hardware accelerated Machine learning

Pick the machine learning container that match your hardware requirements.

A good tip is to run this in a separate machine that is reachable by your immich server, such as a gaming PC. Immich supports multiple machine-learning containers.
This work great but make sure to auto-start the container, or pull it from the main immich container, see the commented out `[install]` section.

## Example deployement with two machines

On my gaming PC that run bazzite I have the `immich-ml-amd.container` under `~/.config/containers/systemd/immich-ml.container`.
With this additional snippet at the end : 
```
[Install]
WantedBy=default.target
```

In the immich configuration the IP address of my gaming PC is set as first priority, then `localhost` as a second machine, so if my PC is
offline, the ML jobs can still run on the NAS CPU.
