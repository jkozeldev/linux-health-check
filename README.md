# Linux Health Check

A Bash script for performing basic Linux system health checks.

## Features

* Hostname, uptime, current user and kernel information
* CPU usage monitoring
* RAM usage monitoring
* Disk usage monitoring
* Internet connectivity check
* DNS resolution check
* System service checks
* Dependency checks
* Exit codes for monitoring/automation
* Optional logging to a file

## Usage
Run the full health check:

bash
./healthcheck.sh


Run individual checks:

bash
./healtcheck.sh --system
./healthcheck.sh --network
./healthcheck.sh --services


Create a log file:

bash
./healthcheck.sh --log


Display available options:

bash
./healthcheck.sh --help


## Exit Codes

* `0` — OK
* `1` — WARNING
* `2` — CRITICAL

The script keeps the highest exit code encountered during the check.

## Requirements

* Bash
* curl
* dig
* systemctl

## Project

This project was created as a hands-on Bash/Linux administration exercise, focusing on scripting, system monitoring, command-line tools, exit codes, functions, loops, and basic troubleshooting.
