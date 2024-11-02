import requests
import re

def get_latest_server_version():
    url = "https://www.minecraft.net/en-us/download/server"
    response = requests.get(url)
    if response.status_code == 200:
        match = re.search(r'https://piston-data\.mojang\.com/v1/objects/[a-f0-9]+/server\.jar', response.text)
        if match:
            return match.group(0)
    return None

latest_url = get_latest_server_version()
if latest_url:
    print(f"Latest Minecraft server URL: {latest_url}")
else:
    print("Failed to fetch the latest server version.")
