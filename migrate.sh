export OLD_VERSION="v1.128.0"
export NEW_VERSION="v1.129.0"
wget "https://github.com/immich-app/immich/releases/download/$NEW_VERSION/docker-compose.yml"
wget "https://github.com/immich-app/immich/releases/download/$NEW_VERSION/example.env"
wget "https://github.com/immich-app/immich/releases/download/$NEW_VERSION/hwaccel.ml.yml"
wget "https://github.com/immich-app/immich/releases/download/$NEW_VERSION/hwaccel.transcoding.yml"
wget "https://github.com/immich-app/immich/releases/download/$NEW_VERSION/prometheus.yml"

DB_IMAGE_TAG=$(yq e '.services.database.image' docker-compose.yml)
sed -i "s|^Image=.*$|Image=${DB_IMAGE_TAG}|" immich-database.container

sed -i "s/${OLD_VERSION}/${NEW_VERSION}/" *.container *.image