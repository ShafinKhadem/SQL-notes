# Usage

### Make user=postgres password=postgres

```
sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';"
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
