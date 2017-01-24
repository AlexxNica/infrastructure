#!/usr/bin/env bash

set -eo pipefail; [[ $SCRIPT_TRACE ]] && set -x

# Collects go-ipfs debug info and publishes it.
#
# Usage:
#
#   > scp scripts/ipfs-debug.sh root@spacerock.i.ipfs.io:/root/
#   > ssh root@spacerock.i.ipfs.io /root/ipfs-debug.sh
#   ...
#   https://ipfs.io/ipfs/QmTzqwxh2kjSQznZh8iYZzeXtQuHZ9pDkocxu184mKJqxd
#

cmd="$1"
[ "$cmd" ] || cmd="docker exec -i ipfs ipfs"

echo ipfs add localhost:5001/debug/pprof/goroutine?debug=2
hash1=$(curl -s 'localhost:5001/debug/pprof/goroutine?debug=2' | $cmd add -q 2>/dev/null)
echo ipfs add localhost:5001/debug/pprof/heap
hash2=$(curl -s 'localhost:5001/debug/pprof/heap'              | $cmd add -q 2>/dev/null)
echo ipfs add localhost:5001/debug/pprof/profile
hash3=$(curl -s 'localhost:5001/debug/pprof/profile'           | $cmd add -q 2>/dev/null)
echo ipfs add localhost:5001/api/v0/diag/sys
hash4=$(curl -s 'localhost:5001/api/v0/diag/sys' | jq .        | $cmd add -q 2>/dev/null)
echo ipfs add /usr/local/bin/ipfs
hash5=$($cmd add -q /usr/local/bin/ipfs 2>/dev/null)

dir0="QmUNLLsPACCz1vLxQVkXqqLX5R1X345qqfHbsf67hvA3Nn"
dir1=$($cmd object patch add-link "$dir0" ipfs.stacks "$hash1" 2>/dev/null)
dir2=$($cmd object patch add-link "$dir1" ipfs.heap "$hash2" 2>/dev/null)
dir3=$($cmd object patch add-link "$dir2" ipfs.cpuprof "$hash3" 2>/dev/null)
dir4=$($cmd object patch add-link "$dir3" ipfs.sysinfo "$hash4" 2>/dev/null)
dir5=$($cmd object patch add-link "$dir4" ipfs "$hash5" 2>/dev/null)

echo "http://localhost:8080/ipfs/$dir5"
echo "https://ipfs.io/ipfs/$dir5"
echo "fs:/ipfs/$dir5"
