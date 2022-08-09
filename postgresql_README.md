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
SHELL := /bin/bash
include .env	# use `make variable=value target` to replace values in .env or any variable in Makefile
# Because of different treatment of quotes by shell (.env) and make, there is no easy way to export
# .env variables from Makefile: https://stackoverflow.com/a/44637188. Verify by adding a `export` here & `make test`.

echo_env:
	env

# variable := $$(command) executes that command each time the variable is used
timestamp := $(shell date -Iseconds)

# https://www.gnu.org/software/make/manual/make.html#Call-Function
# Can't use := here - https://stackoverflow.com/a/6283363
confirm = read -r -p "⚠  Are you sure? [y/N] " response && [[ "$$response" =~ ^([yY][eE][sS]|[yY])$$ ]]

setup_db:
	docker-compose up -d --no-recreate postgres

reset_db:
	@if $(call confirm); then \
		docker exec postgres bash -c "PGPASSWORD=$(DB_PASS) dropdb -h postgres -p 5432 -U $(DB_USER) $(DB_NAME)" ; \
		docker exec postgres bash -c "PGPASSWORD=$(DB_PASS) createdb -h postgres -p 5432 -U $(DB_USER) $(DB_NAME)" ; \
	fi

show_db:
	docker exec postgres bash -c "PGPASSWORD=$(DB_PASS) psql -h postgres -p 5432 -U $(DB_USER) $(DB_NAME) -c \
	'select issue_id, issue_key, board_id, time_to_fix \
	from resolution_events \
	where board_id = '\''$(BOARD_ID)'\'';'"

delete_board:
	@echo -n "This action will delete all data for board $(BOARD_ID). "
	@if $(call confirm); then \
		docker exec postgres bash -c "PGPASSWORD=$(DB_PASS) psql -h postgres -p 5432 -U $(DB_USER) $(DB_NAME) -c \
		'delete from resolution_events \
		where board_id = '\''$(BOARD_ID)'\'';'" ; \
	fi
	@echo "Deleted all data for board $(BOARD_ID)"

fetch_boards:
	# comment out plotting from main.py first
	for id in '719' '509' '543' '546'; do BOARD_ID=$$id poetry run python main.py; done

backup_db:
	docker exec postgres bash -c "PGPASSWORD=$(DB_PASS) pg_dump -h postgres -p 5432 -U $(DB_USER) -d $(DB_NAME) -f /tmp/dump_$(timestamp).sql"
	docker cp postgres:/tmp/dump_$(timestamp).sql ~

restore_db:
	docker cp ~/dump.sql postgres:/tmp/dump.sql
	docker exec postgres bash -c "PGPASSWORD=$(DB_PASS) psql -h localhost -p 5432 -U $(DB_USER) -d $(DB_NAME) -f /tmp/dump.sql"
```
