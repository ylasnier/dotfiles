#!/bin/bash

function usage() {
cat <<EOF
usage: game-mode [options]

game-mode - Set CPU settings for high performance for gaming

OPTIONS:
-e, --enable  :   Set CPU settings to performance
-d, --disable :   Set CPU settings to ondemand
-p, --print   :   Print current CPU settings
-h, --help    :   Print this help message
EOF
}

function set_cpu_scaling_governor_to_ondemand() {
  echo "ondemand" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
  echo "ondemand" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
  echo "ondemand" > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
  echo "ondemand" > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor
}

function set_cpu_scaling_governor_to_performance() {
  echo "performance" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
  echo "performance" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
  echo "performance" > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
  echo "performance" > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor
}

function print_current_cpu_scaling_governor() {
  echo "cpu0:" $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
  echo "cpu1:" $(cat /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor)
  echo "cpu2:" $(cat /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor)
  echo "cpu3:" $(cat /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor)
}

if [ "$#" -eq 0 ]; then
  usage
  exit 0
fi

opts=$(getopt -n "$0" -o edph -l enable,disable,print,help -- "$@")
eval set -- "$opts"

while [ "$#" -gt 0 ]; do
  case $1 in
    -e | --enable)
      echo "Enable game mode"
      set_cpu_scaling_governor_to_performance
      shift
      ;;
    -d | --disable)
      echo "Disable game mode"
      set_cpu_scaling_governor_to_ondemand
      shift
      ;;
    -p | --print)
      print_current_cpu_scaling_governor
      shift
      ;;
    -h | --help)
      usage
      shift
      ;;
    --)
      shift
      break
      ;;
    *)
      shift
      break
      ;;
  esac
done

