import sys
import spotipy
from spotipy.oauth2 import SpotifyClientCredentials

CLIENT_ID = 'SpotifyAPIclientid'
CLIENT_SECRET = 'SpotifyAPIclientsecret'

client_credentials_manager = SpotifyClientCredentials(client_id=CLIENT_ID, client_secret=CLIENT_SECRET)
sp = spotipy.Spotify(client_credentials_manager=client_credentials_manager)

def get_album_release_date(artist_name, album_name):
    try:
        results = sp.search(q=f'artist:{artist_name} album:{album_name}', type='album', limit=1)
        if results['albums']['items']:
            return results['albums']['items'][0]['release_date']
        else:
            return "Date de sortie non trouvée"
    except Exception as e:
        return f"Erreur: {str(e)}"

if __name__ == "__main__":
    if len(sys.argv) == 3:
        artist_name = sys.argv[1]
        album_name = sys.argv[2]
        print(get_album_release_date(artist_name, album_name))
    else:
        print("Usage: python get_album_info.py 'nom_artiste' 'nom_album'")
