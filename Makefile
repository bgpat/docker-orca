PASSWD = password

.PHONY: run setup db passwd

run: setup passwd
	docker-compose up --build orca

setup: db
	docker-compose run orca jma-setup

db: data
	docker-compose up -d db
	docker-compose exec db psql -U orca -c "CREATE EXTENSION IF NOT EXISTS pgcrypto"

passwd: db
	@docker-compose run orca psql -U orca orca -c "INSERT INTO tbl_passwd VALUES ('ormaster', crypt('$(PASSWD)', gen_salt('md5'))) ON CONFLICT (userid) DO UPDATE SET password = crypt('$(PASSWD)', gen_salt('md5'))"

data:
	mkdir data

clean:
	docker-compose down
	sudo rm -rf data
