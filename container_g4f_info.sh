#!/bin/bash

# Nazwa kontenera
CONTAINER_NAME="g4f"


# Pobranie informacji o zużyciu zasobów dla kontenera
CONTAINER_STATS=$(docker stats --no-stream --format '{{json .}}' $CONTAINER_NAME)

# Odczytanie danych z JSON przy użyciu jq
CPU_USAGE=$(echo $CONTAINER_STATS | jq -r '.CPUPerc')
MEMORY_USAGE=$(echo $CONTAINER_STATS | jq -r '.MemUsage')
MEMORY_LIMIT=$(echo $CONTAINER_STATS | jq -r '.MemLimit')

# Usunięcie znaków % z zużycia CPU
CPU_USAGE=${CPU_USAGE//%}

# Konwersja danych pamięci na bajty
MEMORY_USAGE=$(echo $MEMORY_USAGE | awk '{gsub(/[^0-9.]+/, "", $0); printf "%.0f\n", $0}')
MEMORY_LIMIT=$(echo $MEMORY_LIMIT | awk '{gsub(/[^0-9.]+/, "", $0); printf "%.0f\n", $0}')

# Sprawdzenie, czy limit pamięci jest większy niż zero
if [ $MEMORY_LIMIT -gt 0 ]; then
    # Obliczenie procentowego zużycia pamięci
    MEMORY_PERCENT=$(awk "BEGIN {print ($MEMORY_USAGE / $MEMORY_LIMIT) * 100}")
    # Wyświetlenie wyników
    echo "Zużycie pamięci: $MEMORY_PERCENT% ($MEMORY_USAGE MiB of $MEMORY_LIMIT MiB)"
    echo "Zużycie pamięci: $MEMORY_USAGE MiB"
else
    echo ""
fi

# Wyświetlenie zużycia CPU
echo "Zużycie CPU: $CPU_USAGE%"
echo "Zużycie pamięci: $MEMORY_USAGE MiB"
