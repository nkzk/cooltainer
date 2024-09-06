alias nats-top="nats_top"

function nats_top() {
	if [ -n "$NATS_URL" ]; then
		/usr/local/bin/nats-top -s $NATS_URL "$@"
	else
		/usr/local/bin/nats-top "$@"
	fi
}

figlet -p "cooltainer" >&2