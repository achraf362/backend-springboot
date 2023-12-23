# Etape 1: Construction du frontend avec Node.js
FROM node:14-alpine AS frontend-builder

# Définir le répertoire de travail dans l'image Node.js
WORKDIR /app

# Copier uniquement les fichiers nécessaires pour installer les dépendances
COPY package*.json ./

# Installer les dépendances de production
RUN npm ci --only=production

# Copier le reste des fichiers (ignorer ceux listés dans .dockerignore)
COPY . .

# Construire le frontend
RUN npm run build

# Etape 2: Construction de l'application Spring Boot
FROM openjdk:17-jdk-alpine AS backend-builder

# Définir le répertoire de travail dans l'image OpenJDK
WORKDIR /app

# Copier le JAR de l'application Spring Boot
COPY target/spring-boot-data-jpa-0.0.1-SNAPSHOT.jar /app/

# Etape 3: Assemblage de l'image finale
FROM openjdk:17-jdk-alpine

# Définir le répertoire de travail dans l'image finale
WORKDIR /app

# Copier le JAR de l'application depuis l'étape précédente
COPY --from=backend-builder /app/mon-projet.jar .

# Copier les fichiers statiques du frontend depuis l'étape précédente
COPY --from=frontend-builder /app/dist /app/static

# Exposer le port nécessaire par votre application Spring Boot
EXPOSE 8080

# Commande pour démarrer l'application Spring Boot
CMD ["java", "-jar", "spring-boot-data-jpa-0.0.1-SNAPSHOT.jar"]
