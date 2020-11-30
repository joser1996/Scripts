import requests
from bs4 import BeautifulSoup

source = requests.get('https://readberserk.com/').text
soup = BeautifulSoup(source, 'lxml')

tables = soup.findAll("tr")
print("Whatever I found")
print(tables[1])
