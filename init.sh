
set -exuo pipefail

pg_ctl initdb -o "--locale=$LANG"
pg_ctl -w start
createdb $PG_DB
psql --command "CREATE USER $PG_USER WITH REPLICATION SUPERUSER ENCRYPTED PASSWORD '$PG_PASSWORD'"
psql --command "GRANT CREATE ON DATABASE $PG_DB TO $PG_USER"

pg_ctl -w stop
