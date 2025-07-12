import requests
from requests.auth import HTTPBasicAuth

SPLUNK_HOST = 'https://<DS-IP>:8089'
USERNAME = 'UserName'
PASSWORD = 'Password'

requests.packages.urllib3.disable_warnings()

def get_forwarders():
    url = f'{SPLUNK_HOST}/services/deployment/server/clients?output_mode=json'
    r = requests.get(url, auth=HTTPBasicAuth(USERNAME, PASSWORD), verify=False)
    data = r.json()
    for entry in data['entry']:
        name = entry['name']
        last_checkin = entry['content'].get('lastPhoneHomeTime', 'N/A')
        print(f'{name} → Last Check-in: {last_checkin}')

if __name__ == "__main__":
    get_forwarders()
