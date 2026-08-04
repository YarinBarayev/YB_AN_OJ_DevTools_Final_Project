#!/bin/bash
echo "Copying configuration settings..."
docker cp ./settings.php drupal-site:/var/www/html/sites/default/settings.php

echo "Restoring database from drupal_db_backup.sql..."
cat drupal_db_backup.sql | docker exec -i postgres-db psql -U postgres -d drupal_db

echo "Restarting Drupal container..."
docker restart drupal-site

echo "Restore complete! Website is live at http://localhost:8080"