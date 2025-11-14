# Database Backup

This directory contains a systemd service and timer to regularly back up the Immich PostgreSQL database.

## How it Works

- `immich-database-backup.service`: A systemd service that executes a shell script to dump the contents of the PostgreSQL database to a compressed file.
- `immich-database-backup.timer`: A systemd timer that triggers the backup service on a regular schedule (daily by default).

The service will create gzipped SQL dumps named with the date of creation: `YYYYMMDD.sql.gz`.

## Setup

1.  **Create a backup volume:** The database container needs a volume mounted at `/var/db_backup` where the backup files will be stored. You can use a drop-in file to add this volume mount without modifying the original container definition.

    Create the drop-in directory if it doesn't exist:

    ```bash
    mkdir -p /etc/containers/systemd/immich/immich-database.container.d/
    ```

    Copy the provided volume configuration file:

    ```bash
    cp 10-backup-volume.conf /etc/containers/systemd/immich/immich-database.container.d/
    ```

2.  **Enable the backup service:** Place the `immich-database-backup.service` and `immich-database-backup.timer` files in `/etc/systemd/system`.

3.  **Start and enable the timer:**

    ```bash
    systemctl enable --now immich-database-backup.timer
    ```

    This will start the timer, and the first backup will be created according to the schedule defined in the timer unit.