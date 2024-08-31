#!/bin/bash

# Demander à l'utilisateur l'URL de la playlist YouTube
read -p "Quel album voulez-vous télécharger ? (Entrez l'URL YouTube) : " playlist_url

# Vérifier si l'URL a été fournie
if [ -z "$playlist_url" ]; then
    echo "Aucune URL fournie. Le script va se terminer."
    exit 1
fi

# Demander à l'utilisateur de saisir le nom de l'artiste et de l'album
read -p "Entrez le nom de l'artiste : " artist_name
read -p "Entrez le nom de l'album : " album_name

# Utiliser le script Python pour obtenir la date de sortie
release_date=$(python3 get_album_info.py "$artist_name" "$album_name")

# Créer un dossier pour l'album
folder_name=$(echo "$album_name" | sed 's/[^a-zA-Z0-9]/_/g')
mkdir -p "$folder_name"

# Fichier pour stocker les informations
info_file="$folder_name/informations_album.txt"

# Écrire les informations dans le fichier
echo "Artiste : $artist_name" > "$info_file"
echo "Album : $album_name" >> "$info_file"
echo "Date de sortie de l'album : $release_date" >> "$info_file"

# Télécharger l'image de l'album
image_name=$(echo "$album_name" | sed 's/[^a-zA-Z0-9]/_/g')
yt-dlp --write-thumbnail --skip-download --convert-thumbnails png \
    -o "$folder_name/$image_name" "$playlist_url"

# Renommer l'image si nécessaire
if [ -f "$folder_name/$image_name.webp" ]; then
    mv "$folder_name/$image_name.webp" "$folder_name/$image_name.png"
fi

# Télécharger et convertir chaque piste en MP3, et collecter les durées
yt-dlp -i --extract-audio --audio-format mp3 --audio-quality 0 \
    -o "$folder_name/%(playlist_index)s-%(title)s.%(ext)s" \
    --print "before_dl:%(playlist_index)s-%(title)s.mp3 : %(duration)s" \
    "$playlist_url" | tee -a "$info_file"

echo "Téléchargement de l'album terminé dans le dossier: $folder_name"
echo "Les informations de l'album ont été enregistrées dans $info_file"
echo "L'image de l'album a été enregistrée sous le nom: $image_name.png"
