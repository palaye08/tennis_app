# 🎾 Plan CI/CD — Projet Tennis App
## Conteneurisation, GitHub & Pipeline CI/CD

---

## ✅ PARTIE 1 — INITIALISATION DU PROJET AVEC GIT

### Étape 1 — Initialiser le dépôt Git local
```bash
git init
```
**Utilité :** Crée un dépôt Git local dans le dossier du projet.
Génère un dossier caché `.git/` qui va suivre toutes les modifications du code.

---

### Étape 2 — Lier le dépôt local au dépôt GitHub distant
```bash
git remote add origin https://github.com/palaye08/tennis_app.git
```
**Utilité :** Connecte ton dépôt local à GitHub.
`origin` est le nom donné à l'adresse distante. C'est la convention standard.

---

### Étape 3 — Créer un fichier .gitignore
```bash
echo "target/" >> .gitignore
echo ".env" >> .gitignore
echo "*.class" >> .gitignore
```
**Utilité :** Indique à Git les fichiers à ne pas suivre
(dossier de build Maven, fichiers sensibles, fichiers compilés).

---

### Étape 4 — Ajouter tous les fichiers au suivi Git
```bash
git add .
```
**Utilité :** Prépare tous les fichiers du projet pour le commit.
Le `.` signifie "tout le dossier courant".

---

### Étape 5 — Créer le premier commit
```bash
git commit -m "init: initialisation du projet Tennis App Spring Boot"
```
**Utilité :** Enregistre un instantané du projet avec un message descriptif.
C'est le point de départ de l'historique du code.

---

### Étape 6 — Renommer la branche principale en main
```bash
git branch -M main
```
**Utilité :** Renomme la branche par défaut en `main`
(standard GitHub actuel, remplace l'ancien `master`).

---

### Étape 7 — Pousser le code vers GitHub
```bash
git push -u origin main
```
**Utilité :** Envoie le code local vers GitHub sur la branche `main`.
`-u` crée le lien de suivi entre la branche locale et distante.

---

## ✅ PARTIE 2 — WORKFLOW BRANCHES (Feature Branch)

### Étape 8 — Créer et basculer sur la branche de développement
```bash
git checkout -b feature/tennis-crud
```
**Utilité :** Crée une nouvelle branche `feature/tennis-crud` et s'y place.
Permet de développer sans toucher à la branche `main` protégée.

---

### Étape 9 — Travailler et commiter sur la branche
```bash
git add .
git commit -m "feat: ajout CRUD match de tennis avec Swagger"
```
**Utilité :** Sauvegarde les modifications sur la branche de fonctionnalité.
Convention de message : `feat:` pour nouvelle fonctionnalité.

---

### Étape 10 — Pousser la branche vers GitHub
```bash
git push origin feature/tennis-crud
```
**Utilité :** Envoie la branche sur GitHub pour créer une Pull Request.

---

### Étape 11 — Créer une Pull Request sur GitHub
> Aller sur https://github.com/palaye08/tennis_app
> Cliquer sur **"Compare & pull request"**
> Titre : `feat: CRUD match de tennis`
> Cliquer sur **"Create pull request"**

**Utilité :** Permet la revue de code avant fusion dans `main`.
C'est la pratique standard en équipe.

---

### Étape 12 — Merger la Pull Request dans main
> Sur GitHub : cliquer sur **"Merge pull request"** → **"Confirm merge"**

Puis en local synchroniser :
```bash
git checkout main
git pull origin main
```
**Utilité :** Intègre le code validé dans la branche principale.

---

## ✅ PARTIE 3 — DOCKER ET DOCKERHUB

### Étape 13 — Builder le projet Maven (créer le JAR)
```bash
mvn clean package -DskipTests
```
**Utilité :** Compile le code Java et crée le fichier `.jar` dans `target/`.
`-DskipTests` ignore les tests pour aller plus vite.

---

### Étape 14 — Se connecter à Docker Hub
```bash
docker login
```
**Utilité :** Authentifie ton terminal auprès de Docker Hub
pour pouvoir pousser des images.

---

### Étape 15 — Builder l'image Docker
```bash
docker build -t palaye08/tennis-backend:1.0 .
```
**Utilité :** Crée une image Docker du backend à partir du `Dockerfile`.
`palaye08/tennis-backend:1.0` = username/nom-image:version

---

### Étape 16 — Pousser l'image sur Docker Hub
```bash
docker push palaye08/tennis-backend:1.0
```
**Utilité :** Envoie l'image sur Docker Hub.
Elle sera accessible publiquement et utilisable partout.

---

### Étape 17 — Lancer les conteneurs avec Docker Compose
```bash
docker-compose up -d
```
**Utilité :** Lance MySQL et le backend en arrière-plan (`-d` = detached).

---

### Étape 18 — Vérifier que les conteneurs tournent
```bash
docker-compose ps
```
**Utilité :** Affiche l'état de tous les conteneurs du projet.
Les deux doivent être en statut `Up`.

---

### Étape 19 — Voir les logs du backend
```bash
docker-compose logs -f backend
```
**Utilité :** Affiche les logs en temps réel du backend.
Utile pour déboguer si l'application ne démarre pas.

---

### Étape 20 — Arrêter les conteneurs
```bash
docker-compose down
```
**Utilité :** Arrête et supprime les conteneurs.
Les volumes de données (MySQL) sont conservés.

---

## ✅ RÉSULTAT ACTUEL ✅

```
NAME             IMAGE                   STATUS         PORTS
tennis-backend   projet-tennis-backend   Up             0.0.0.0:8082->8081/tcp
tennis-mysql     mysql:8.0               Up             0.0.0.0:3307->3306/tcp
```

**Swagger accessible sur :**
```
http://localhost:8082/swagger-ui/index.html
```

---

## 🔜 PARTIE 4 — CI/CD AVEC GITHUB ACTIONS (prochaine étape)

> Voir le fichier `.github/workflows/ci-cd.yml` à créer.
> Pipeline prévu : Push → Build → Test → Docker Build → Push Docker Hub → Deploy
> 
> les etapes les plus claire 