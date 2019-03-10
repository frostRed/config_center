#!/bin/sh
docker build --force-rm=true -t config_center:latest .
docker image prune --force