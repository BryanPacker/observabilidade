#!/bin/bash

# Este script é executado como o usuário 'ubuntu' no $PROJECT_DIR

# O PROJECT_DIR é o diretório atual (.), mas vamos usar o caminho completo por segurança.
PROJECT_DIR="/home/ubuntu/Aula-Observabilidade"

# Cria a estrutura de pastas
mkdir -p $PROJECT_DIR/nginx/certs

# Gerar Certificado SSL Autoassinado
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout $PROJECT_DIR/nginx/certs/nginx.key \
  -out $PROJECT_DIR/nginx/certs/nginx.crt \
  -subj "/C=BR/ST=SC/L=Blumenau/O=DevOps/OU=IT/CN=observabilidade.local"

# Criar usuário e senha para o Basic Auth (admin / DevJunior)
htpasswd -bc $PROJECT_DIR/nginx/.htpasswd admin DevJunior