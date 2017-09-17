#!/bin/bash -e
clear
docker ps --format 'table {{.Names}}\t{{.Ports}}' | grep myapp | sort
