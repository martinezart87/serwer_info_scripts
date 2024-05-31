#!/bin/bash

# Nazwa kontenera
CONTAINER_NAME="g4f"

# Pobranie adresu IP kontenera
CONTAINER_IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_NAME)
CONTAINER_NAME=$(docker inspect -f '{{.Name}}' $CONTAINER_NAME | sed 's/^\///')

# Wyświetlenie adresu IP i nazwy kontenera
echo "$CONTAINER_NAME"
echo "$CONTAINER_IP"
