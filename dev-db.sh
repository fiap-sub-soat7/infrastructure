#!/bin/bash
echo "------------------------"
echo "start dev SOAT 7 T75 dbs"
echo "------------------------"

dcFile='development/docker-compose.yaml'
docker compose -f $dcFile --project-directory ../ up db-svc-mongo db-svc-mysql -d