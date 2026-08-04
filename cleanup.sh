#!/bin/bash
echo "Cleaning up Docker environment..."
docker stop drupal-site postgres-db
docker rm drupal-site postgres-db
docker network rm drupal-net
docker image rm drupal:latest postgres:latest
echo "Cleanup finished! System is clear."