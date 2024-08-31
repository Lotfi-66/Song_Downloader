#!/bin/bash

# Fichiers pour stocker les derniers IDs utilisés
SONG_ID_FILE="last_used_song_id.txt"
ALBUM_ID_FILE="last_used_album_id.txt"

# Fonction pour échapper les caractères spéciaux dans les chaînes SQL
escape_sql() {
    echo "$1" | sed "s/'/\\\'/g" | sed 's/"/\\"/g'
}

# Fonction pour extraire le titre du file_path
extract_title() {
    echo "$1" | sed -E 's/^[0-9]+-(.*)\.mp3$/\1/'
}

# Fonction pour nettoyer le file_path
clean_file_path() {
    echo "$1" | sed -E 's/[\/\?\!\\]//g' | tr -s ' '
}

# Lire le dernier ID de chanson utilisé s'il existe
if [ -f "$SONG_ID_FILE" ]; then
    last_id=$(cat "$SONG_ID_FILE")
    read -p "Entrez l'ID de départ (dernier ID utilisé: $last_id): " input_id
    # Si l'utilisateur n'entre rien, utiliser le dernier ID
    last_id=${input_id:-$last_id}
else
    read -p "Entrez l'ID de départ: " last_id
fi

# Variable pour stocker toutes les requêtes SQL
all_sql_queries=""

while true; do
    # Lire le dernier ID d'album utilisé s'il existe
    if [ -f "$ALBUM_ID_FILE" ]; then
        last_album_id=$(cat "$ALBUM_ID_FILE")
        read -p "Entrez l'album_id (dernier ID utilisé: $last_album_id): " input_album_id
        # Si l'utilisateur n'entre rien, utiliser le dernier ID
        album_id=${input_album_id:-$last_album_id}
    else
        read -p "Entrez l'album_id: " album_id
    fi

    echo "Collez la liste des titres (format: 01-Titre.mp3 : durée). Entrez une ligne vide pour terminer."
    
    # Lire les titres
    while IFS= read -r input; do
        # Sortir de la boucle si la ligne est vide
        [ -z "$input" ] && break

        # Extraire file_path et duration
        file_path=$(echo "$input" | awk -F' : ' '{print $1}')
        duration=$(echo "$input" | awk -F' : ' '{print $NF}')

        # Nettoyer le file_path
        clean_path=$(clean_file_path "$file_path")

        # Extraire le titre du file_path nettoyé
        title=$(extract_title "$clean_path")

        # Échapper les chaînes pour la requête SQL
        escaped_title=$(escape_sql "$title")
        escaped_file_path=$(escape_sql "$clean_path")

        # Créer la requête SQL et l'ajouter à la liste
        sql="INSERT INTO song (id, album_id, title, file_path, duration) VALUES ($last_id, $album_id, \"$escaped_title\", \"$escaped_file_path\", $duration);"
        all_sql_queries+="$sql"$'\n'

        # Incrémenter l'ID pour la prochaine chanson
        last_id=$((last_id + 1))
    done

    # Enregistrer le dernier ID d'album utilisé
    echo "$album_id" > "$ALBUM_ID_FILE"

    # Demander à l'utilisateur s'il veut ajouter un autre album
    read -p "Voulez-vous ajouter un autre album ? (o/n): " add_album
    if [ "$add_album" != "o" ]; then
        break
    fi
done

# Afficher toutes les requêtes SQL générées
echo "Toutes les requêtes SQL générées :"
echo "$all_sql_queries"

# Décrémenter last_id pour obtenir le dernier ID réellement utilisé
last_id=$((last_id - 1))

# Enregistrer le dernier ID de chanson utilisé
echo "$last_id" > "$SONG_ID_FILE"

echo "Fin du programme. Le dernier ID de chanson utilisé ($last_id) et le dernier ID d'album utilisé ($album_id) ont été enregistrés."
