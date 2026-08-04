#!/bin/bash
echo "Creating Docker network..."
docker network create drupal-net

echo "Starting Postgres Container..."
docker run -d \
  --name postgres-db \
  --network drupal-net \
  -p 5432:5432 \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=my-secret-pw \
  -e POSTGRES_DB=drupal_db \
  postgres:latest

echo "Starting Drupal Container..."
docker run -d \
  --name drupal-site \
  --network drupal-net \
  -p 8080:80 \
  -v drupal_files:/var/www/html/sites \
  drupal:latest

echo "Setup complete!"