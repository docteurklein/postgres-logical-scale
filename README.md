# postgres-logical-scale

## what ? 

A logical-replication-ready postgres@10beta2 docker image.

## how ?

### build a custom image

    docker build \
        --build-arg PG_USER=florian \
        --build-arg PG_PASSWORD=test \
        --build-arg PG_DB=test \
        -t pg10 .

### create the primary

    docker volume create pgmaster

    docker service create --name pgmaster \
        -e IS_MASTER=1 \
        -v pgmaster:/var/lib/data/postgres \
        pg10

### create a replica

    docker service create --name pgreplica \
        -e MASTER_HOST=pgmaster \
        -e PG_USER=florian -e PG_PASSWORD=test -e PG_DB=test \
        pg10


### scale it!

    docker service scale pgreplica=10

