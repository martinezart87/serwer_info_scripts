#!/bin/bash

# Nazwa kontenera
CONTAINER_NAME="g4f"

# Pobranie informacji o zużyciu zasobów dla kontenera
CONTAINER_STATS=$(docker stats --no-stream --format '{{json .}}' $CONTAINER_NAME)

# Odczytanie danych z JSON przy użyciu jq
CPU_USAGE_CONTAINER=$(echo $CONTAINER_STATS | jq -r '.CPUPerc')
MEMORY_USAGE_CONTAINER=$(echo $CONTAINER_STATS | jq -r '.MemUsage')
MEMORY_LIMIT_CONTAINER=$(echo $CONTAINER_STATS | jq -r '.MemLimit')

# Usunięcie znaków % z zużycia CPU
CPU_USAGE_CONTAINER=${CPU_USAGE_CONTAINER//%}

# Konwersja danych pamięci na bajty
MEMORY_USAGE_CONTAINER=$(echo $MEMORY_USAGE_CONTAINER | awk '{gsub(/[^0-9.]+/, "", $0); printf "%.0f\n", $0}')
MEMORY_LIMIT_CONTAINER=$(echo $MEMORY_LIMIT_CONTAINER | awk '{gsub(/[^0-9.]+/, "", $0); printf "%.0f\n", $0}')

# Obliczenie procentowego zużycia pamięci
if [ $MEMORY_LIMIT_CONTAINER -gt 0 ]; then
    MEMORY_PERCENT_CONTAINER=$(awk "BEGIN {print ($MEMORY_USAGE_CONTAINER / $MEMORY_LIMIT_CONTAINER) * 100}")
else
    MEMORY_PERCENT_CONTAINER=0
fi

# Pobranie adresu IP kontenera
CONTAINER_IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_NAME)
CONTAINER_NAME=$(docker inspect -f '{{.Name}}' $CONTAINER_NAME | sed 's/^\///')

# Zużycie CPU systemu
CPU_USAGE_SYSTEM=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')

# Zużycie pamięci RAM systemu
MEMORY_USAGE_SYSTEM=$(free -m | awk 'NR==2{printf "%.2f", $3*100/$2}')
MEMORY_USED_SYSTEM=$(free -m | awk 'NR==2{printf "%.2f MiB", $3}')
MEMORY_TOTAL_SYSTEM=$(free -m | awk 'NR==2{printf "%.2f MiB", $2}')

# Zużycie SWAP systemu
SWAP_USAGE_SYSTEM=$(free -m | awk 'NR==3{printf "%.2f", $3*100/$2}')
SWAP_USED_SYSTEM=$(free -m | awk 'NR==3{printf "%.2f MiB", $3}')
SWAP_TOTAL_SYSTEM=$(free -m | awk 'NR==3{printf "%.2f MiB", $2}')

# Rozmiar dysku systemu
DISK_USAGE_SYSTEM=$(df -h | grep '^/dev/' | awk '{used+=$3; total+=$2} END {print used*100/total}')
DISK_USED_SYSTEM=$(df -h | grep '^/dev/' | awk '{used+=$3} END {print used}')
DISK_TOTAL_SYSTEM=$(df -h | grep '^/dev/' | awk '{total+=$2} END {print total}')

# Pobranie adresu IP serwera
SERVER_IP=$(hostname -I | awk '{print $1}')
SERVER_NAME=$(hostname)

# Pobranie czasu działania kontenera w sekundach i w formacie ludzkim
STARTED_AT=$(docker inspect --format='{{.State.StartedAt}}' $CONTAINER_NAME)
CURRENT_TIME=$(date +%s)
CONTAINER_UPTIME_SECONDS=$((CURRENT_TIME - $(date -d "$STARTED_AT" +%s)))
CONTAINER_UPTIME_HUMAN=$(date -u -d @$CONTAINER_UPTIME_SECONDS +"%jd %Hh %Mm %Ss")

# Pobranie czasu działania serwera w sekundach i w formacie ludzkim
SERVER_UPTIME_SECONDS=$(date +%s -d "$(uptime -s)")
SERVER_UPTIME_HUMAN=$(uptime -p)

# Pobranie listy plików z katalogu /root/update_g4f/har_and_cookies/
FILES=$(ls /root/update_g4f/har_and_cookies/ 2>/dev/null)

# Tworzenie JSON z wynikami
JSON_RESULT=$(jq -n \
    --arg container_name "$CONTAINER_NAME" \
    --arg container_ip "$CONTAINER_IP" \
    --arg cpu_usage_container "$CPU_USAGE_CONTAINER%" \
    --arg memory_usage_container "$MEMORY_USAGE_CONTAINER MiB" \
    --arg memory_limit_container "$MEMORY_LIMIT_CONTAINER MiB" \
    --arg memory_percent_container "$(printf "%.2f" $MEMORY_PERCENT_CONTAINER)%" \
    --arg cpu_usage_system "$CPU_USAGE_SYSTEM% z $(nproc) CPU(s)" \
    --arg memory_usage_system "$MEMORY_USAGE_SYSTEM%" \
    --arg memory_used_system "$MEMORY_USED_SYSTEM" \
    --arg memory_total_system "$MEMORY_TOTAL_SYSTEM" \
    --arg swap_usage_system "$SWAP_USAGE_SYSTEM%" \
    --arg swap_used_system "$SWAP_USED_SYSTEM" \
    --arg swap_total_system "$SWAP_TOTAL_SYSTEM" \
    --arg disk_usage_system "$(printf "%.2f" $DISK_USAGE_SYSTEM)%" \
    --arg disk_used_system "$DISK_USED_SYSTEM GiB" \
    --arg disk_total_system "$DISK_TOTAL_SYSTEM GiB" \
    --arg server_name "$SERVER_NAME" \
    --arg server_ip "$SERVER_IP" \
    --arg files "$FILES" \
    --arg container_uptime_human "$CONTAINER_UPTIME_HUMAN" \
    --arg container_uptime_seconds "$CONTAINER_UPTIME_SECONDS" \
    --arg server_uptime_human "$SERVER_UPTIME_HUMAN" \
    --arg server_uptime_seconds "$SERVER_UPTIME_SECONDS" \
    '{
        container: {
            name: $container_name,
            ip: $container_ip,
            cpu_usage: $cpu_usage_container,
            memory_usage: $memory_usage_container,
            memory_limit: $memory_limit_container,
            memory_percent: $memory_percent_container,
            uptime_human: $container_uptime_human,
            uptime_seconds: $container_uptime_seconds
        },
        system: {
            cpu_usage: $cpu_usage_system,
            memory: {
                usage: $memory_usage_system,
                used: $memory_used_system,
                total: $memory_total_system
            },
            swap: {
                usage: $swap_usage_system,
                used: $swap_used_system,
                total: $swap_total_system
            },
            disk: {
                usage: $disk_usage_system,
                used: $disk_used_system,
                total: $disk_total_system
            },
            uptime_human: $server_uptime_human,
            uptime_seconds: $server_uptime_seconds
        },
        server: {
            name: $server_name,
            ip: $server_ip
        },
        files: ($files | split("\n") | map(select(length > 0)))
    }'
)

# Wyświetlenie
echo "$JSON_RESULT"
