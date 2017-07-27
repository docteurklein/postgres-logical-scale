
set -exuo pipefail

pg_ctl -w start

if [ "$IS_MASTER" -eq '1' ];then
    psql -U $PG_USER --command "CREATE PUBLICATION alltables FOR ALL TABLES" || true
fi

if [ -n "$MASTER_HOST" ]; then
    pg_dump -s --no-publication --no-subscription -Fc -w -Z 1 --dbname="postgresql://$PG_USER:$PG_PASSWORD@$MASTER_HOST:5432/$PG_DB" | pg_restore -Fc -U $PG_USER -d $PG_DB
    psql -U $PG_USER --command "CREATE SUBSCRIPTION alltables_$(hostname) CONNECTION 'host=$MASTER_HOST dbname=$PG_DB user=$PG_USER password=$PG_PASSWORD' PUBLICATION alltables" $PG_DB
fi

pg_ctl -w stop

exec "$@"
