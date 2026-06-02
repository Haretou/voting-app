# Image de base Python 3.13 slim
FROM python:3.13-slim

# Répertoire de travail dans le container
WORKDIR /app

# Copie et installation des dépendances en premier (meilleur cache Docker)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copie du code source
COPY main.py .
COPY config_file.cfg .

# Copie des fichiers statiques et templates
COPY static/ ./static/
COPY templates/ ./templates/

# Variables d'environnement requises par l'application
ENV REDIS=""
ENV REDIS_PWD=""

# Exposition du port 80
EXPOSE 80

# Healthcheck sur la route principale
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:80')" || exit 1

# Lancement de Flask sur le port 80
CMD ["flask", "--app", "main", "run", "--host=0.0.0.0", "--port=80"]
