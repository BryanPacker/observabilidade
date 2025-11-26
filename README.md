# 🚀 Projeto de Observabilidade: Stack Prometheus, Grafana e Nginx Secure

Este projeto configura uma stack completa de observabilidade em um host Linux (AWS EC2), utilizando a rede Docker para isolamento de serviços e Nginx para fornecer uma camada de segurança robusta com SSL e autenticação básica.

A infraestrutura é provisionada via Terraform, e a configuração da aplicação é feita via User Data e Docker Compose.

---

## 💡 1. Visão Geral da Arquitetura

O tráfego externo só é permitido através das portas **80** e **443**, gerenciadas pelo Nginx. Todos os serviços de coleta de métricas e visualização operam em uma rede interna isolada do Docker, sem exposição direta à internet.

| Componente | Imagem Base | Porta Interna (Docker) | Porta Exposta (Host) | Acesso Externo |
| :--- | :--- | :--- | :--- | :--- |
| **Node Exporter** | `obs-node-exporter` | 9100 | Nenhuma | **NÃO** |
| **Ping Exporter** | `czerwonk/ping_exporter` | 9427 | Nenhuma | **NÃO** |
| **Prometheus** | `obs-prometheus` | 9090 | Nenhuma | **NÃO** |
| **Grafana** | `obs-grafana` | 3000 | Nenhuma | **NÃO** |
| **Nginx Proxy** | `nginx:alpine` | 443 | 80, 443 | **SIM** |

> **Nota de Segurança:** O Security Group da AWS deve permitir entrada apenas nas portas `22` (SSH), `80` (HTTP) e `443` (HTTPS).

---

## 📦 2. Estrutura do Projeto

```text
.
├── docker-compose.yml              # Configuração base dos serviços de monitoramento
├── docker-compose.override.yml     # Adiciona o serviço Nginx e mapeia portas 80/443
├── nginxpasswrd.sh                 # Script de automação de segurança (SSL e Auth)
├── user_data.sh                    # Script de inicialização da EC2
│
├── grafana/
│   ├── Dockerfile
│   └── provisioning/               # Provisionamento automático de Dashboards/Datasources
│
├── prometheus/
│   └── prometheus.yml              # Configuração de scrape
│
└── nginx/
    └── conf.d/
        └── default.conf            # Regras de Reverse Proxy e Autenticação
📜 3. Automação e Scripts
Script de Segurança (nginxpasswrd.sh)
Este script é executado automaticamente pelo user_data ao iniciar a máquina. Ele é responsável por:

Gerar certificados SSL autoassinados para HTTPS.

Criar o arquivo .htpasswd para a camada de autenticação do Nginx.

Bash

#!/bin/bash
PROJECT_DIR="/home/ubuntu/Aula-Observabilidade"
mkdir -p $PROJECT_DIR/nginx/certs

# 1. Gerar Certificado SSL Autoassinado
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout $PROJECT_DIR/nginx/certs/nginx.key \
  -out $PROJECT_DIR/nginx/certs/nginx.crt \
  -subj "/C=BR/ST=SC/L=Blumenau/O=DevOps/OU=IT/CN=observabilidade.local"

# 2. Criar usuário e senha para o Basic Auth
# Credenciais padrão: admin / DevJunior
htpasswd -bc $PROJECT_DIR/nginx/.htpasswd admin DevJunior
☁️ 4. Deploy na AWS (Terraform)
Inicialização (user_data)
O script abaixo é injetado pelo Terraform no recurso aws_instance. Ele prepara o ambiente Docker, clona este repositório, configura a segurança e sobe a stack.

Bash

#!/bin/bash
sleep 20
apt-get update
apt-get install -y docker.io git apache2-utils openssl

# Configuração do Docker
systemctl start docker
systemctl enable docker
usermod -aG docker ubuntu

# Instalação do Docker Compose
curl -SL [https://github.com/docker/compose/releases/download/v2.29.0/docker-compose-linux-x86_64](https://github.com/docker/compose/releases/download/v2.29.0/docker-compose-linux-x86_64) -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

# Setup do Projeto
PROJECT_DIR="/home/ubuntu/Aula-Observabilidade"
# Substitua pela URL do seu repositório real
sudo -u ubuntu git clone [https://github.com/BryanPacker/observabilidade.git](https://github.com/BryanPacker/observabilidade.git) $PROJECT_DIR

# Configuração de Segurança e Deploy
sudo -u ubuntu bash -c "cd $PROJECT_DIR && chmod +x nginxpasswrd.sh && ./nginxpasswrd.sh"
chown -R ubuntu:ubuntu $PROJECT_DIR
sudo -u ubuntu bash -c "cd $PROJECT_DIR && docker-compose -f docker-compose.yml -f docker-compose.override.yml up -d"
Executando o Terraform
No diretório do Terraform:

Bash

terraform init
terraform apply
🔑 5. Acesso e Autenticação
Após a conclusão do provisionamento, o Grafana estará acessível via HTTPS. Devido ao certificado autoassinado, o navegador pode exibir um alerta de segurança (prossiga aceitando o risco).

URL: https://[IP_PÚBLICO_DA_EC2]

O acesso possui dupla camada de autenticação:

Nginx Basic Auth (Pop-up do navegador):

User: admin

Pass: DevJunior

Grafana Login (Interface):

User: admin

Pass: DevJunior (ou a senha definida no grafana.ini)
