import requests
response = requests.get('https://autoderm.ai/v1/utils/healthz')
print(response.text)