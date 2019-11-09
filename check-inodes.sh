#!/bin/sh

MOUNTPOINTS="${MOUNTPOINTS:-/var/lib/docker /data/var_lib_docker}"
THRESHOLD="${THRESHOLD:-50}"
FILTER="${FILTER:-unused-for=1h}"
SLEEP="${SLEEP:-600}"

IDENTIFIER="${IDENTIFIER:-$(hostname -s)}"
if [ ! -z "${HOST_IP}" ]; then
  IDENTIFIER="${IDENTIFIER}:${HOST_IP}"
fi

PATH=$PATH:/usr/local/bin

sleep 60

while true; do

  for MP in ${MOUNTPOINTS} ; do
    if [ ! -d "${MP}" ]; then continue; fi
    PERCENT="$(df --output=ipcent "${MP}" | tail -n 1 | sed 's|[^[:digit:]]*||g')"
    if [ "${PERCENT}" -lt "${THRESHOLD}" ]; then
      printf '[%s] inode usage %d%% for %s - No action taken\n' "${IDENTIFIER}" "${PERCENT}" "${MP}"
    else
      printf '[%s] inode usage %d%% for %s - Pruning\n' "${IDENTIFIER}" "${PERCENT}" "${MP}"
      docker builder prune --force --filter "${FILTER}"
      printf '[%s] prune finished\n' "${IDENTIFIER}"
      sleep 900
    fi
  done

  sleep "${SLEEP}"

done


