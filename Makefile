DBUSER := orca
DBNAME := orca

.PHONY: run setup init db passwd restore clean

run: setup
	docker-compose up --build orca

setup: db
	docker-compose run --rm orca jma-setup

init: passwd

db: data
	docker-compose up -d db
	@until docker-compose exec db psql -U $(DBUSER) -c "SELECT 1" > /dev/null 2>&1; do \
		echo "Waiting for postgres server..." ; \
		sleep 1 ; \
	done

passwd: db
	docker-compose exec db psql -U $(DBUSER) -c "CREATE EXTENSION IF NOT EXISTS pgcrypto"
	@read -s -p "password: " DBPASS; \
	docker-compose run --rm orca psql -U $(DBUSER) -c "INSERT INTO tbl_passwd VALUES ('ormaster', crypt('$$DBPASS', gen_salt('md5'))) ON CONFLICT (userid) DO UPDATE SET password = crypt('$$DBPASS', gen_salt('md5'))"

restore: restore/*.dump clean db
	docker-compose run --rm orca psql -U $(DBUSER) -c "DROP SCHEMA public"
	COMPOSE_INTERACTIVE_NO_CLI=1 docker-compose exec db find /tmp/restore -name '*.dump' -exec pg_restore -Fc -x -O -U $(DBUSER) -d $(DBNAME) {} \;

data:
	mkdir data

clean:
	docker-compose down
	sudo rm -rf data
