#!/bin/bash
echo "Backing up Postgres database..."
docker exec postgres-db sh -c 'exec pg_dump -U postgres drupal_db' > drupal_db_backup.sql
echo "Backup saved to drupal_db_backup.sql"