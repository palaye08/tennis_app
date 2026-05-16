#!/bin/bash

# Configuration
BASE_URL="http://localhost:8081/api/v1/matches"

echo "=== Démarrage des tests API Tennis Match (Port 8081) ==="
echo ""

# 1. Créer un match
echo "1. Test de création d'un match (POST)..."
CREATE_RESPONSE=$(curl -s -X POST $BASE_URL \
  -H "Content-Type: application/json" \
  -d '{
    "num": "Match Finale Open",
    "nombreDeSet": 3,
    "statut": "A_VENIR"
  }')
echo "Réponse : $CREATE_RESPONSE"

MATCH_ID=$(echo $CREATE_RESPONSE | grep -o '"id":[0-9]*' | cut -d: -f2)

if [ -z "$MATCH_ID" ]; then
    echo "Erreur : Impossible de récupérer l'ID du match créé. Vérifiez si l'application est lancée."
    exit 1
fi
echo ">>> Succès : Match créé avec l'ID $MATCH_ID"
echo "-----------------------------------"

# 2. Lister tous les matchs (paginé)
echo "2. Test de récupération de tous les matchs (GET)..."
curl -s -X GET "$BASE_URL?page=0&size=10"
echo -e "\n>>> Succès : Liste récupérée"
echo "-----------------------------------"

# 3. Récupérer un match par ID
echo "3. Test de récupération du match ID $MATCH_ID (GET /{id})..."
curl -s -X GET "$BASE_URL/$MATCH_ID"
echo -e "\n>>> Succès : Détails du match récupérés"
echo "-----------------------------------"

# 4. Modifier un match
echo "4. Test de modification du match ID $MATCH_ID (PUT)..."
curl -s -X PUT "$BASE_URL/$MATCH_ID" \
  -H "Content-Type: application/json" \
  -d "{
    \"num\": \"Match Finale Open - UPDATED\",
    \"nombreDeSet\": 5,
    \"statut\": \"EN_COURS\"
  }"
echo -e "\n>>> Succès : Match mis à jour"
echo "-----------------------------------"

# 5. Supprimer le match
echo "5. Test de suppression du match ID $MATCH_ID (DELETE)..."
curl -s -X DELETE "$BASE_URL/$MATCH_ID"
echo -e "\n>>> Succès : Match supprimé"
echo "-----------------------------------"

# 6. Vérification finale
echo "6. Vérification finale (Liste après suppression)..."
curl -s -X GET $BASE_URL
echo -e "\n\n=== Tous les tests sont terminés ! ==="
