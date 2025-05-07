#!/bin/sh
set -e # Quitte immédiatement si une commande échoue

# Créer le répertoire pour les certificats
mkdir -p /etc/fleet-telemetry/certs

# Écrire le certificat serveur depuis la variable d'environnement secret
echo "$SERVER_CERT_PEM" > /etc/fleet-telemetry/certs/server.pem
if [ $? -ne 0 ]; then echo "Erreur: Écriture de server.pem échouée"; exit 1; fi

# Écrire la clé privée serveur depuis la variable d'environnement secret
echo "$SERVER_KEY_PEM" > /etc/fleet-telemetry/certs/server-key.pem
if [ $? -ne 0 ]; then echo "Erreur: Écriture de server-key.pem échouée"; exit 1; fi
# Sécuriser la clé privée
chmod 600 /etc/fleet-telemetry/certs/server-key.pem

echo "$APP_CONFIG_JSON" > /etc/fleet-telemetry/config.json
if [ $? -ne 0 ]; then echo "Erreur: Écriture de config.json échouée"; exit 1; fi

# (Optionnel) Écrire les credentials GCP si Pub/Sub est utilisé
if [ -n "$GOOGLE_APPLICATION_CREDENTIALS_JSON" ]; then
  mkdir -p /etc/gcp
  printf '%s' "$GOOGLE_APPLICATION_CREDENTIALS_JSON" > /etc/gcp/credentials.json
  if [ $? -ne 0 ]; then echo "Erreur: Écriture de credentials.json échouée"; exit 1; fi
  export GOOGLE_APPLICATION_CREDENTIALS=/etc/gcp/credentials.json
fi

# Affichez un message pour confirmer (utile pour le débogage des logs)
echo "Certificats et credentials écrits. Démarrage de fleet-telemetry..."

# Exécute la commande principale de l'image Docker
# Utilise le config.json monté ou celui inclus dans l'image si non monté
exec /usr/local/bin/fleet-telemetry -config=/etc/fleet-telemetry/config.json