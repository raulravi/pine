#!/bin/bash
ret=true
getent passwd pine >/dev/null 2>&1 && ret=false
if $ret; then
	useradd -d /opt/pine -s /bin/bash -U pine
fi
