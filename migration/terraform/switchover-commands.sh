#!/bin/bash

redis-cli -h "redis-1.internal.vizard.gcp" \
  -a "${REDIS_PASS}" \
  --cluster call "redis-1.internal.vizard.gcp:6379" CONFIG SET requirepass "locked_password"

redis-cli -h "redis-1.internal.vizard.gcp" \
  -a "locked_password" \
  --cluster call "redis-1.internal.vizard.gcp:6379" CLIENT KILL TYPE normal SKIPME yes
