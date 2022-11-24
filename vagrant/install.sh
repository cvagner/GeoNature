#!/bin/bash

# Gestion des erreurs (le script est arrêté à la première erreur)
abort() {
  (RED='\033[0;31m' && NC='\033[0m' && printf "${RED}\n- ABORTED - Installation interrompue -\n${NC}" >&2)
  exit 1
}
trap 'abort' ERR
set -e


# Dans le répertoire et en root
cd $(dirname $0)

if ( ! (whoami | grep root > /dev/null) ); then
  echo && echo "Pas root : sudo su"
  sudo su
fi


# Etapes

gn_msg() {
  echo
  echo "┌──────────────────────────────────────┄┄"
  echo "│ $1"
  echo "└──────────────────────────────────────┄┄"
  echo
}


gn_preparation_sys() {
  gn_msg "🍸 Préparation Système : mise à jour, utilitaires et locale"

  # Mise à jour et paquets utilitaires
  apt update && apt upgrade -y
  apt install -y curl wget htop fontconfig

  # Locale fr_FR.UTF-8
  if ! (locale | grep "LANG=fr_FR.UTF-8" > /dev/null); then
    echo "Ajout de la locale fr_FR.UTF-8"
    (cat /etc/locale.gen | grep "^fr_FR.UTF-8 UTF-8" > /dev/null) || echo "fr_FR.UTF-8 UTF-8" >> /etc/locale.gen

    echo "Génération de la locale fr_FR.UTF-8"
    locale-gen fr_FR.UTF-8
  fi
}


gn_preparation_app() {
  gn_msg "🍿 Préparation Application : utilisateur et scripts"

  # Utilisateur geonatureadmin
  if ! id -u geonatureadmin > /dev/null 2>&1; then
    adduser --disabled-password --gecos "" geonatureadmin
    adduser geonatureadmin sudo
    echo "geonatureadmin ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/geonatureadmin
  fi

  # Script d'installation et de la configuration par défaut
  GN_HOME=/home/geonatureadmin
  GN_GITHUB_BASE_URL="${GN_VERSION:-https://raw.githubusercontent.com/PnX-SI/GeoNature}"
  GN_VERSION="${GN_VERSION:-2.10.3}"
  GN_INSTALL_ALL_BASE_URL="${GN_GITHUB_BASE_URL}/${GN_VERSION}/install/install_all"
  wget "${GN_INSTALL_ALL_BASE_URL}/install_all.ini" -O $GN_HOME/install_all.ini
  wget "${GN_INSTALL_ALL_BASE_URL}/install_all.sh" -O $GN_HOME/install_all.sh

  chown geonatureadmin:geonatureadmin $GN_HOME/install_all.*
  chmod +x $GN_HOME/install_all.sh
}


gn_configuration() {
  gn_msg "🔧 Configuration"

  GN_DATABASE_USERNAME="${GN_DATABASE_USERNAME:-geonatadmin}"
  GN_DATABASE_PASSWORD="${GN_DATABASE_PASSWORD:-monpassachanger}"
  GN_BASE_URL="${GN_BASE_URL:-http://localhost:8881/}"

  # On aurait aussi pu écrire directement le fichier install_all.ini complet.
  sed -i "s/^user_pg=.*/user_pg=${GN_DATABASE_USERNAME}/g" /home/geonatureadmin/install_all.ini
  sed -i "s/^user_pg_pass=.*/user_pg_pass=${GN_DATABASE_PASSWORD}/g" /home/geonatureadmin/install_all.ini
  sed -i "s%^my_url=.*%my_url=${GN_BASE_URL}%g" /home/geonatureadmin/install_all.ini
}


gn_installation() {
  gn_msg "🎧 Installation"

  su -c '/home/geonatureadmin/install_all.sh 2>&1 | tee /home/geonatureadmin/install_all.log' - geonatureadmin
}


gn_check() {
  gn_msg "✓ Vérifications des applications"

  sleep 5
  echo • geonature : $(curl -s -o /dev/null -w "%{http_code}" localhost/geonature/)
  echo • taxhub : $(curl -s -o /dev/null -w "%{http_code}" localhost/taxhub/)
  echo • usershub : $(curl -s -o /dev/null -w "%{http_code}" localhost/usershub/login)
}


gn_postgresql_listen_all() {
  gn_msg "✓ Autorisation de l'écoute de PostgreSQL sur le réseau"

  sed -i "s/^#listen_addresses = '.*/listen_addresses = '*'/g" /etc/postgresql/11/main/postgresql.conf
  echo "host geonature2db all 0.0.0.0/0 md5" >> /etc/postgresql/11/main/pg_hba.conf
  systemctl restart postgresql
}


# On démarre !

echo && echo "👋 Démarrage de l'installation"

gn_preparation_sys
gn_preparation_app
gn_configuration
gn_installation
gn_check

gn_postgresql_listen_all

echo && echo "👌 Fin de l'installation"
