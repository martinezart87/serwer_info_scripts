#!/bin/bash

# Zużycie CPU
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
echo "Zużycie CPU: $CPU_USAGE% z $(nproc) CPU(s)"

# Zużycie pamięci RAM
MEMORY_USAGE=$(free -m | awk 'NR==2{printf "%.2f", $3*100/$2}')
MEMORY_USED=$(free -m | awk 'NR==2{printf "%.2f MiB", $3/1024}')
MEMORY_TOTAL=$(free -m | awk 'NR==2{printf "%.2f GiB", $2/1024}')
echo "Zużycie pamięć: $MEMORY_USAGE% ($MEMORY_USED z $MEMORY_TOTAL)"

# Zużycie SWAP
SWAP_USAGE=$(free -m | awk 'NR==3{printf "%.2f", $3*100/$2}')
SWAP_USED=$(free -m | awk 'NR==3{printf "%.2f MiB", $3}')
SWAP_TOTAL=$(free -m | awk 'NR==3{printf "%.2f MiB", $2}')
echo "Zużycie SWAP: $SWAP_USAGE% ($SWAP_USED z $SWAP_TOTAL)"

# Rozmiar dysku
DISK_USAGE=$(df -h | grep '^/dev/' | awk '{used+=$3; total+=$2} END {print used*100/total}')
DISK_USED=$(df -h | grep '^/dev/' | awk '{used+=$3} END {print used}')
DISK_TOTAL=$(df -h | grep '^/dev/' | awk '{total+=$2} END {print total}')
echo "Dysk twardy: $DISK_USAGE% ($DISK_USED GiB z $DISK_TOTAL GiB)"

