#!/bin/bash
echo "------------------------"
echo "start dev SOAT 7 T75 env"
echo "------------------------"

dcFile='development/docker-compose.yaml'
# docker compose -f $dcFile --project-directory ../ down
docker compose -f $dcFile --project-directory ../ up db-svc-mongo -d
docker compose -f $dcFile --project-directory ../ up app-svc-vehicle
