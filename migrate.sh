NEW_VERSION="$1"
if [ -z $1 ]; then
	echo "usage: ./migrate.sh v1.129.0"
	exit
fi
echo "migrate to $1"

wget -q "https://github.com/immich-app/immich/releases/download/$NEW_VERSION/docker-compose.yml"

DB_IMAGE_TAG=$(yq e '.services.database.image' docker-compose.yml)
sed -i "s|^Image=.*$|Image=${DB_IMAGE_TAG}|" immich-database.container
REDIS_IMAGE_TAG=$(yq e '.services.redis.image' docker-compose.yml)
sed -i "s|^Image=.*$|Image=${REDIS_IMAGE_TAG}|" immich-redis.container


sed -i "s/v[0-9]\.[0-9]\{3\}\.[0-9]/${NEW_VERSION}/" *.container *.image

rm docker-compose.yml
