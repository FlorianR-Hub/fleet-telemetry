# Initialisation du projet sans déployer
fly launch --no-deploy --copy-config --name fleet-telemetry

# Ajout des secrets
fly secrets set SERVER_CERT_PEM="$(cat secrets/certificate.pem)" --app fleet-telemetry
fly secrets set SERVER_KEY_PEM="$(cat secrets/private.key)" --app fleet-telemetry
fly secrets set APP_CONFIG_JSON="$(cat secrets/config.json)" --app fleet-telemetry
fly secrets set GOOGLE_APPLICATION_CREDENTIALS_JSON="$(cat secrets/credentials.json)" --app fleet-telemetry

# Pour avoir une adresse IPV4 dédiée
fly ips allocate-v4 --app=fleet-telemetry

# Déploiement
fly deploy

# Pour reboot les machines
fly apps restart fleet-telemetry

# Pour n'avoir qu'une seule machine
fly scale count 1