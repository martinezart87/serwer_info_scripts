#!/bin/bash

# Pobranie adresu IP serwera
SERVER_IP=$(hostname -I | awk '{print $1}')
SERVER_NAME=$(hostname)

# Wyświetlenie adresu IP i nazwy serwera
echo "$SERVER_NAME"
echo "$SERVER_IP"
