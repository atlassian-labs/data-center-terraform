# Current version: 5.1.2

# Restoring Crowd from backup

To restore  Crowd from backup, we need a pre-provisioned database
and `crowd.cfg.xml` containing database details and license. If new Crowd versions aren't compatible with existing database dump, generate a new one.

## Create SQL dump

Start Postgres database:

```bash
docker run -d --name=postgres -e POSTGRES_PASSWORD=crowd -e POSTGRES_USER=postgres -e POSTGRES_DB=crowd -e PGDATA=/var/lib/postgresql/data/pgdata -p 5432:5432 postgres:14
```

Start Crowd and link postgres container:

```
docker run -ti --link postgres -p 8095:9085 atlassian/crowd:$version
```

Go to `http://localhost:8095` and complete Crowd installation. DB hostname will be `postgres`.

Go to Applications -> **crowd-openid-server**, change password, save it to `TF_VAR_CROWD_ADMIN_PASSWORD` secret in GitHub actions. Update this secret in https://github.com/atlassian/data-center-helm-charts repository as well.

Then, go to Remote addresses and add 0.0.0.0/0 to allow connections from all IPs.

Once done, exec into postgres container to dump the db:

```
docker exec postgres sh -c "export PGPASSWORD=crowd; pg_dump -U postgres crowd >/opt/crowd.sql"
```

Exit the container and copy the file to a local folder:

```
docker cp postgres:/opt/crowd.sql .
```
Replace crowd.sql file with a new one, update Current version in this README.