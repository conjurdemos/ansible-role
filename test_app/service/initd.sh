#!/bin/sh

### BEGIN INIT INFO
# Provides:          test_appdaemon
# Required-Start:    $local_fs $network $syslog
# Required-Stop:     $local_fs $network $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Test app
# Description:       Test app start-stop-daemon - Debian
### END INIT INFO

# Quick start-stop-daemon example, derived from Debian /etc/init.d/ssh
# Include functions
set -e

. /lib/lsb/init-functions

# load environment (TODO: lol what about multiline env vars ?)
eval $(xargs -0 bash -c 'printf "export %q\n" "$@"' -- < /proc/1/environ)

# Must be a valid filename
NAME=$APP_NAME
PIDFILE=/var/run/$NAME.pid
LOGFILE=/var/log/summon-$NAME.log
SUMMON_PIDFILE=/var/run/summon-$NAME.pid
#This is the command to be run, give the full pathname
DAEMON=/usr/local/bin/summon
APP_ROOT=/opt/app
DAEMON_OPTS="-D ENV=$ENV -w  --watch-poll-interval 30000 -- rackup -p 4567 --host 0.0.0.0 -P $PIDFILE"

export PATH="${PATH:+$PATH:}/usr/sbin:/sbin"

start() {
  echo "Starting daemon: "$NAME
	start-stop-daemon -b -v  --make-pidfile --pidfile $SUMMON_PIDFILE --chdir $APP_ROOT --start  --startas /bin/bash -- -c "exec $DAEMON $DAEMON_OPTS > $LOGFILE 2>&1"
  echo "."
}

stop() {
  echo "Stopping daemon: "$NAME
	start-stop-daemon --stop --quiet --oknodo --retry 2 --remove-pidfile --pidfile $PIDFILE
	rm -rf $PIDFILE

	start-stop-daemon --stop --quiet --oknodo --retry 2 --remove-pidfile --pidfile $SUMMON_PIDFILE
	rm -rf $SUMMON_PIDFILE

  echo "."
}

status() {
  local total_status=1
  if ! status_of_proc -p $SUMMON_PIDFILE "-" summon ; then total_status=0; fi
  if ! status_of_proc -p $PIDFILE "-" $NAME ; then total_status=0; fi

  [ $total_status -ne 0 ] && exit 0 || exit $?
}

case "$1" in
  start)
    start
	;;
  stop)
    stop
	;;
  restart)
    echo "Restarting daemon: "$NAME
    stop
    start
	;;
	status)
    status
	;;

  *)
	echo "Usage: "$1" {start|stop|restart|status}"
	exit 1
esac

exit 0
