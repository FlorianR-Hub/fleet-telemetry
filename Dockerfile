# Dockerfile
# --- Stage 1: Récupérer le binaire de l'image officielle ---
FROM tesla/fleet-telemetry:latest as extractor

# --- Stage 2: Image finale basée sur Debian (qui contient /bin/sh) ---
FROM debian:stable-slim

# Installer les certificats CA (bonne pratique, souvent nécessaire pour HTTPS sortant, ex: vers GCP)
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates && rm -rf /var/lib/apt/lists/*

# Définir le répertoire de travail (optionnel mais propre)
WORKDIR /app

# Copier le binaire fleet-telemetry depuis le stage extractor
COPY --from=extractor /fleet-telemetry /usr/local/bin/fleet-telemetry

# Copier notre script d'entrypoint personnalisé
COPY ./fly/entrypoint.sh /app/entrypoint.sh

# Rendre l'entrypoint exécutable DANS le conteneur
RUN chmod +x /app/entrypoint.sh

# Définir l'entrypoint pour utiliser notre script via le shell
ENTRYPOINT ["/bin/sh", "/app/entrypoint.sh"]

# Exposer le port (documentaire, Fly utilise la section [services])
EXPOSE 443
