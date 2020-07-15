#!/usr/bin/env bash
set -eou pipefail
cd `dirname "$0"`

export dc=${dc:-1}
export VIRTUAL_HOST_1=example-one.com
export VIRTUAL_HOST_2=example-two.net

hosts=/etc/hosts
hosts_tmp=`mktemp`

curl-x() { set -x; curl "$@"; { set +x; } 2> /dev/null; }
check-dir() { [ -d $1 ] || { mkdir $1; echo "$2" > $1/index.html; }; }

check-dir example-one 1
check-dir example-two 2

while :
do
  case "${1:-}" in
    up|down)
      cmd="docker-compose -f docker-compose.$dc.yml $1"; shift
      $cmd "$@"
      exit $?
      ;;
    virtual-hosts-add)
      echo -e "# VH BEGIN\n127.0.0.1	$VIRTUAL_HOST_1 $VIRTUAL_HOST_2\n# VH END" | sudo tee -a $hosts
      exit $?
      ;;
    virtual-hosts-del)
      sed "/^# VH BEGIN$/,/^# VH END$/d" $hosts > $hosts_tmp
      sudo mv $hosts_tmp $hosts
      exit $?
      ;;
    curl-1) curl-x http://localhost:8000 ;;
    curl-2) curl-x http://localhost:9000 ;;
    curl-vh1) curl-x http://$VIRTUAL_HOST_1 ;;
    curl-vh2) curl-x http://$VIRTUAL_HOST_2 ;;
    *)
      echo "Usage: $0 <up|down|virtual-hosts-<add|del>|curl-<1,2>> [args]"
      exit 0
      ;;
  esac
  shift || :
  [ "${1:-}" ] || break
done
