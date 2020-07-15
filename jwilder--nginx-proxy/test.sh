#!/usr/bin/env bash
set -eou pipefail

export VIRTUAL_HOST=${VIRTUAL_HOST:-whoami.local}

hosts=/etc/hosts
hosts_tmp=`mktemp`

curl-x() { set -x; curl "$@"; { set +x; } 2> /dev/null; }

case "${1:-}" in
  up|down)
    cmd="docker-compose $1"; shift
    $cmd "$@"
    ;;
  virtual-host-add) echo "127.0.0.1	$VIRTUAL_HOST" | sudo tee -a $hosts;;
  virtual-host-del)
    sed "/$VIRTUAL_HOST$/d" $hosts > $hosts_tmp
    sudo mv $hosts_tmp $hosts
    ;;
  curl-1) curl-x $VIRTUAL_HOST;;
  curl-2) curl-x -H "Host: $VIRTUAL_HOST" localhost;;
  *) echo "Usage: $0 <up|down|host-<add|del>|curl-<1,2>> [args]"
esac
