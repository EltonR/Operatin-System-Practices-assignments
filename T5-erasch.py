#!/usr/bin/python

import subprocess
import os
import requests
import shutil
import urllib

from bs4 import BeautifulSoup
from os.path import expanduser


print("Checando diretorio 'phd'")
if os.path.isdir("phd/"):
	print("Diretorio existente. Limpando...")
	shutil.rmtree("phd/")
	os.makedirs("phd/")
else:
	print("Diretorio inexistente. Criando...")
	os.makedirs("phd/")

pagina = "http://phdcomics.com/"
print("Iniciando download das imagens...") 
i = 0

while True:
	
	soup = BeautifulSoup(requests.get(pagina).content, 'html.parser')
	tirinha = soup.find("img", {"id": "comic"}).get('src')
	anterior = soup.find('img', src=lambda i: i and 'prev_button.gif' in i).parent.get('href')
	img = tirinha.split("/")
	print("Baixando imagem '"+img[5]+"'")
	urllib.urlretrieve(tirinha, "phd/"+img[5])

	if i == 0:
		pagina = "http://phdcomics.com/" + anterior
	elif i == 4:
		break
	else:
		pagina = "http://phdcomics.com/comics/" + anterior
	i += 1




