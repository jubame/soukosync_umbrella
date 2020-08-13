#!/bin/sh
# Docker entrypoint script.

# Wait until Postgres is ready
echo "${DB_HOST}"
echo "${DB_USER}"
while ! pg_isready -q -h $DB_HOST -p 5432 -U $DB_USER
do
  echo "$(date) - waiting for database to start"
  sleep 2
done

"./prod/rel/soukosync/bin/soukosync" eval "Soukosync.Release.migrate" && \
"./prod/rel/soukosync/bin/soukosync" start
