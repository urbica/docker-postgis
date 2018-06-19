#!/bin/bash
set -e

# MASTER REPLICATION MODE
if [[ $POSTGRES_REPLICATION_MODE = "master" ]]
	then
	echo "Initializing replication master..."

	echo "Creating '$POSTGRES_REPLICATION_USER' replication user..."
	psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
		CREATE USER $POSTGRES_REPLICATION_USER WITH REPLICATION PASSWORD '$POSTGRES_REPLICATION_PASSWORD';
		GRANT ALL PRIVILEGES ON DATABASE $POSTGRES_DB TO $POSTGRES_REPLICATION_USER;
	EOSQL

	cat <<-EOF >> $PGCONFD/00-master.conf
		wal_level = replica
		max_wal_senders = 3
		wal_keep_segments = 64
	EOF

	echo "host replication $POSTGRES_REPLICATION_USER all md5" >> "$PGDATA/pg_hba.conf"
	PGUSER="${PGUSER:-postgres}" pg_ctl -D "$PGDATA" -m fast -w restart
fi

# SLAVE REPLICATION MODE
if [[ $POSTGRES_REPLICATION_MODE = "slave" ]]
then
	echo "Initializing replication slave..."

	PGUSER="${PGUSER:-postgres}" pg_ctl -D "$PGDATA" -m fast -w stop
	rm -rf $PGDATA/*

	PGPASSWORD=$POSTGRES_REPLICATION_PASSWORD pg_basebackup -h $POSTGRES_MASTER_HOST -D $PGDATA -P -U $POSTGRES_REPLICATION_USER --wal-method=stream

	cat <<-EOF >> $PGDATA/recovery.conf 
		standby_mode      = 'on'
		primary_conninfo  = 'host=$POSTGRES_MASTER_HOST port=$POSTGRES_MASTER_PORT user=$POSTGRES_REPLICATION_USER password=$POSTGRES_REPLICATION_PASSWORD'
		trigger_file      = '/tmp/promote_me_to_master'
	EOF

	cat <<-EOF >> $PGCONFD/00-slave.conf
		hot_standby = on
	EOF

	PGUSER="${PGUSER:-postgres}" \
	pg_ctl -D "$PGDATA" \
		-o "-c listen_addresses=''" \
		-w start
fi
