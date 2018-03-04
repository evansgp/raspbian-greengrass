#!/bin/sh
### BEGIN INIT INFO
# Provides:          greengrass.sh
# Required-Start: 
# Required-Stop:
# Default-Start: S 2 3 4 5
# Default-Stop:
# Short-Description: Run AWS Greengrass
# Description:
### END INIT INFO

. /lib/lsb/init-functions

case "$1" in
  start)
    /greengrass/ggc/packages/1.3.0/greengrassd start
    ;;
  stop)
    /greengrass/ggc/packages/1.3.0/greengrassd stop
    ;;
  restart)
    /greengrass/ggc/packages/1.3.0/greengrassd restart
    ;;
  force-reload)
    /greengrass/ggc/packages/1.3.0/greengrassd stop
    /greengrass/ggc/packages/1.3.0/greengrassd start
    ;;
  *)
    echo "Usage: $0 start" >&2
    exit 3
    ;;
esac
