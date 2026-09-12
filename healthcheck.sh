#!/bin/bash


#Exit code function
set_exit_code() {

        NEW_CODE=$1
  # echo "debug: NEW_CODE=$NEW_CODE EXIT_CODE=$EXIT_CODE"


      if [ "$NEW_CODE" -gt "$EXIT_CODE" ]; then
          EXIT_CODE=$NEW_CODE
        fi
}


# System check
check_system() {

# data a  promenne
SERVER_HOSTNAME=$(hostname)
UPTIME=$(uptime -p)
CURRENT_USER=$(whoami)
KERNEL_VERSION=$(uname -r)

TOTAL_RAM=$(free -m | grep Mem | awk '{print $2}')
USED_RAM=$(free -m | grep Mem | awk '{print $3}')
RAM_USAGE=$((USED_RAM * 100 / TOTAL_RAM))

DISK_USAGE=$(df -h / | awk 'NR==2{print $5}' | tr -d '%')

CPU_IDLE=$(top -bn2 -d 0.5 | awk '/Cpu\(s\)/ {for (i=1; i<=NF; i++) if ($i ~ /id,?/) print $(i-1)}'| tail -1)
CPU_USAGE=$(awk "BEGIN {print 100 - $CPU_IDLE}")

# Output

echo "================="
echo "Linux Health Check"
echo "================="

echo "Date: $(date)"
echo "Hostname: $SERVER_HOSTNAME"
echo "Uptime: $UPTIME"
echo "User: $CURRENT_USER"
echo "Kernel Version: $KERNEL_VERSION"
echo "RAM USAGE: $RAM_USAGE%"
echo "Disk Usage: $DISK_USAGE"


#CPU Threshold

if awk "BEGIN {exit !($CPU_USAGE >= 90)}"; then

	echo "CPU: $CPU_USAGE% - CRITICAL"
	set_exit_code 2

  elif awk "BEGIN {exit !($CPU_USAGE >= 80)}"; then

  	echo "CPU: $CPU_USAGE% - WARNING" 
	set_exit_code 1

 else 

	echo  "CPU: $CPU_USAGE% - OK"
fi

#RAM Usage Threshold


 if [ "$RAM_USAGE" -ge 90 ]; then
        echo "RAM: $RAM_USAGE% - CRITICAL"
         set_exit_code 2

elif [ "$RAM_USAGE" -ge 80 ]; then
        echo "RAM: $RAM_USAGE% - WARNING"
         set_exit_code 1
  else
        echo "RAM: $RAM_USAGE% - OK"
fi


# Disk Usage Thresholds

 if [ "$DISK_USAGE" -ge 90 ]; then
        echo "Disk: DISK_USAGE% - CRITICAL"
        set_exit_code 2
 elif [ "$DISK_USAGE" -ge 80 ]; then
        echo  "DISK:$DISK_USAGE% - WARNING"
        if [ "$EXIT_CODE" -lt 1 ]; then
        set_exit_code 1
        fi
 else
        echo "Disk: $DISK_USAGE% - OK"
 fi



}


# Network checks

check_internet() {

if curl -I --max-time 5 https://google.com > /dev/null 2>&1; then
	echo "Internet: OK"
	return 0
else
	echo "Internet: Fail"
	return 1
fi
}

check_dns(){

if dig google.com > /dev/null 2>&1; then
	echo "DNS: OK"
	return 0
else 
	echo "DNS: Failed"
	return 1
fi
}

check_services() {

	SERVICES=("docker" "nginx" "ssh")

for SERVICE in "${SERVICES[@]}"; do 

	if systemctl is-active --quiet "$SERVICE"; then
	echo "$SERVICE: OK"
else
    	echo "$SERVICE: FAILED"

	set_exit_code 1
fi


done

}


#Dependencies check for commands

check_dependencies() {

  COMMANDS=("curl" "dig" "systemctl")

for COMMAND in "${COMMANDS[@]}"; do 

  if command -v "$COMMAND" > /dev/null 2>&1; then

	echo "$COMMAND: OK"

  else

        echo "$COMMAND: MISSING"
	set_exit_code 2
     fi

 done
}

#Main

EXIT_CODE=0


check_dependencies

case "$1" in 

	"")

check_system

if ! check_internet; then
    set_exit_code 1
  
fi


if ! check_dns; then
   set_exit_code 1
fi


check_services

;;


--system)
  check_system
;;


--network)
  if ! check_internet; then
     set_exit_code 1
  fi

  if ! check_dns; then
    set_exit_code 1
  fi
  ;;


--services)
  check_services
  ;;


--log)
	exec > >(tee healthcheck.log) 2>&1
	

	check_system

 if ! check_internet; then
	set_exit_code 1
 fi

 if ! check_dns; then
	set_exit_code 1

 fi

check_services

;;


--help)
echo "Linux Health Check"

echo

echo "Usage:"

echo " ./healthcheck.sh"

echo " ./healthcheck.sh --log"

echo " ./healthcheck.sh --system"

echo " ./healthcheck.sh --network"

echo " ./healthcheck.sh --services"

echo " ./healthcheck.sh --help"

;;

*)
	echo "unknown option: $1"
	echo "Use --help for available options"
	exit 1
	;;
esac

exit $EXIT_CODE



