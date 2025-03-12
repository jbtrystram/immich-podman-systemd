OLD_VERSION="$1"
NEW_VERSION="$2"
if [ -z $2 ]; then
	echo "usage: ./migrate.sh v1.128.0 v1.129.0"
	exit
fi
echo "$1 -> $2"

wget -q "https://github.com/immich-app/immich/releases/download/$NEW_VERSION/docker-compose.yml"

DB_IMAGE_TAG=$(yq e '.services.database.image' docker-compose.yml)
sed -i "s|^Image=.*$|Image=${DB_IMAGE_TAG}|" immich-database.container
REDIS_IMAGE_TAG=$(yq e '.services.redis.image' docker-compose.yml)
sed -i "s|^Image=.*$|Image=${REDIS_IMAGE_TAG}|" immich-redis.container


sed -i "s/${OLD_VERSION}/${NEW_VERSION}/" *.container *.image

rm docker-compose.yml
