# Usage

### Make user=postgres password=postgres

```
sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';"
```

Try to connect using psql -U postgres and you may be getting [error: Peer authentication failed for user "postgres"](https://stackoverflow.com/q/18664074) (follow the link for solution).

### create DB & open psql shell using .env:

```bash
set -a; . .env; set +a
PGPASSWORD=$DB_PASS createdb -h $DB_HOST -p $DB_PORT -U $DB_USER $DB_NAME
PGPASSWORD=$DB_PASS psql -h $DB_HOST -p $DB_PORT -U $DB_USER $DB_NAME
```

### backup sourcedb

```
PGPASSWORD=postgres pg_dump -h localhost -U postgres -d sourcedb -f ~/Downloads/dump.sql
```

### drop targetdb

```
PGPASSWORD=postgres dropdb -h localhost -U postgres targetdb
```

### create targetdb

```
PGPASSWORD=postgres createdb -h localhost -U postgres targetdb
```

### restore database to targetdb

```
PGPASSWORD=postgres psql -h localhost -U postgres -d targetdb -f ~/Downloads/dump.sql
```

### If you mess up any sequence

```
alter sequence "Users_id_seq" restart with 101;
```

### extract ERD in crows-foot

use [pgmodeler](https://pgmodeler.io/)

### tips

**don't use uppercase anywhere.**

You may check out pg_ctl and postgres commands

see [notes](notes.txt)

docker-compose.yml for postgres:

```yaml
services:
  postgres:
    image: postgres:latest
    container_name: postgres
    ports:
      - "5432:5432"
    environment:
      POSTGRES_DB: jira_metrics
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: password
    volumes:
      - postgres:/var/lib/postgresql/data
    networks:
      - postgres

networks:
  postgres:
    driver: bridge

volumes:
  postgres:
```

A Makefile for postgres with above docker & .env:

```make
export	# export all variables by default
include .env	# To override these variables, use make variable=value target

echo_env:
	env

setup_db:
	docker-compose up -d --no-recreate postgres

reset_db:
	docker exec postgres bash -c "PGPASSWORD=$(DB_PASS) dropdb -h postgres -p 5432 -U $(DB_USER) $(DB_NAME)"
	docker exec postgres bash -c "PGPASSWORD=$(DB_PASS) createdb -h postgres -p 5432 -U $(DB_USER) $(DB_NAME)"

show_db:
	docker exec postgres bash -c "PGPASSWORD=$(DB_PASS) psql -h postgres -p 5432 -U $(DB_USER) $(DB_NAME) -c \
	'select avg(abs(time_to_fix-time_to_fix_master)), percent_rank(1.1) within group (order by abs(time_to_fix-time_to_fix_master)) \
	from resolution_events \
	join \
	(select issue_id, sum(time_to_fix) as time_to_fix_master \
	from resolution_events_master \
	group by issue_id) \
	as resolution_events_master \
	using (issue_id);'"

backup_db:
	PGPASSWORD=$(DB_PASS) pg_dump -h localhost -p 5432 -U $(DB_USER) -d $(DB_NAME) -f ~/dump_$$(date -Iseconds).sql

restore_db: reset_db
	PGPASSWORD=$(DB_PASS) psql -h localhost -p 5432 -U $(DB_USER) -d $(DB_NAME) -f ~/dump.sql
```
