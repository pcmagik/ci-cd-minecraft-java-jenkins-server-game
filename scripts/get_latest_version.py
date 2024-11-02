import requests

def get_latest_minecraft_server_url():
    # Zakładam, że korzystasz z publicznego API Mojangu do pobrania najnowszej wersji
    version_manifest_url = 'https://launchermeta.mojang.com/mc/game/version_manifest.json'
    response = requests.get(version_manifest_url)

    if response.status_code == 200:
        version_data = response.json()
        latest_release = version_data['latest']['release']
        for version in version_data['versions']:
            if version['id'] == latest_release:
                download_url = version['url']
                version_response = requests.get(download_url)
                if version_response.status_code == 200:
                    version_info = version_response.json()
                    server_url = version_info['downloads']['server']['url']
                    return server_url
                else:
                    print("Błąd podczas pobierania szczegółów wersji.")
                    return None
        print("Nie znaleziono odpowiedniej wersji.")
        return None
    else:
        print("Błąd podczas pobierania manifestu wersji.")
        return None

url = get_latest_minecraft_server_url()
if url:
    print(url)
else:
    print("Nie udało się pobrać najnowszego URL.")
