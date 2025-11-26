#!/bin/bash

PROJECT_DIR="/home/ubuntu/Aula-Observabilidade"

# 1. Instalar utilitários necessários
apt-get update
# Necessário para htpasswd (segurança) e openssl (certificados)
apt-get install -y apache2-utils openssl

# 2. Criar a estrutura para os segredos do Nginx
mkdir -p $PROJECT_DIR/nginx/certs

# 3. Gerar Certificado SSL Autoassinado (Para porta 443)
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout $PROJECT_DIR/nginx/certs/nginx.key \
  -out $PROJECT_DIR/nginx/certs/nginx.crt \
  -subj "/C=BR/ST=SC/L=Blumenau/O=DevOps/OU=IT/CN=observabilidade.local"

# 4. Criar o usuário e senha para o Basic Auth
# Usuário: admin / Senha: DevJunior
htpasswd -bc $PROJECT_DIR/nginx/.htpasswd admin DevJunior

# 5. Ajustar permissões e rodar o Docker Compose
# Isso é crucial, pois rodamos os comandos acima como root (apt/openssl)
chown -R ubuntu:ubuntu $PROJECT_DIR

# O Docker Compose lerá o override.yml que você adicionou no GitHub
sudo -u ubuntu bash -c "cd $PROJECT_DIR && docker-compose up -d"