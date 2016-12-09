#!/usr/bin/python

import os
import sys
reload(sys)
sys.setdefaultencoding('utf-8')
rootFolder = sys.argv[1]

# Tryes to import Eyed3 and PyLyrics. If there are not present, will offer to download them...
try:
    import eyed3
except ImportError:
	import subprocess
	resp= raw_input("\nEyed3 library not found. Would you like to install it? [Y]es [N]o\n")
	if(resp == "no" or resp == "No" or resp == "NO" or resp == "n" or resp == "N"):
		sys.exit()
	# subprocess 'call' waits until process is finished
	process = subprocess.call("pip install eye3D", shell=True)
	import eyed3

try:
	from PyLyrics import *
except ImportError:
	import subprocess
	resp = raw_input("\nPyLyrics library not found. Would you like to install it? [Y]es [N]o\n")
	if (resp == "no" or resp == "No" or resp == "NO" or resp == "n" or resp == "N"):
		sys.exit()
	process = subprocess.call("pip install PyLyrics", shell=True)
	from PyLyrics import *


# checks if the root folder is passed and navigates to it...
if len(sys.argv) != 2:
	print "Execution: t_final <root folder to search>"
	sys.exit()
os.chdir(sys.argv[1])

# this options tells wether the lyrics should by placed on folder passed by argument or
# should be placed on the folders of the songs.
folderToStore = "";
while (folderToStore != "1" and folderToStore != "2"):
	folderToStore = raw_input('Where do you want the lyrics to be stored?\n[1] on the root folder \t[2] on the folder of music\'s file\n')

# this variable specifies if only one file will contain the lyrics or if there will
# be one file per lyric.
uniqueFile = "";
while (uniqueFile != "1" and uniqueFile != "2"):
	uniqueFile = raw_input('Group songs?\n[1] Store artist/album lyrics at same file \t\t[2] one file per song\n*Option 1 supposes subfolders are of name of albums...\n')

# does the trick!
# not found/problem lyrics are stored on a file, on the folder from which the programm is called
for sys.argv[1], dirs, files in os.walk(".", topdown=False):
	for name in files:
		if(name.endswith(".mp3")):
			try:
				audiofile = eyed3.load(os.path.join(sys.argv[1], name))
				if(folderToStore=="1"):
					if(uniqueFile=="2"):
						lyricFile = open(rootFolder+audiofile.tag.artist.decode('utf-8')+" - "+audiofile.tag.title.decode('utf-8')+".txt", "w")
					else:
						lyricFile = open(rootFolder + audiofile.tag.artist.decode('utf-8') + ".txt", "a")
				else:
					if (uniqueFile == "2"):
						lyricFile = open(os.path.abspath(os.path.join(sys.argv[1]))+"/"+audiofile.tag.artist.decode('utf-8') + " - " + audiofile.tag.title.decode('utf-8') + ".txt", "w")
					else:
						lyricFile = open(os.path.abspath(os.path.join(sys.argv[1]))+"/"+audiofile.tag.artist.decode('utf-8') + ".txt", "a")
				lyricFile.write('\n-------------------------------------\n' + audiofile.tag.artist.decode('utf-8') + ' - ' + audiofile.tag.title.decode('utf-8') + '\n')
				lyrics = PyLyrics.getLyrics(audiofile.tag.artist.decode('utf-8'), audiofile.tag.title.decode('utf-8'))
				lyricFile.write(lyrics)
				audiofile.tag.lyrics.set(u'' + lyrics)
				audiofile.tag.save()
				#print(audiofile.tag.lyrics.set(lyrics))
			except Exception, e:
				print("Couldn\'t find lyrics for \""+audiofile.tag.artist.decode('utf-8') + ' - ' + audiofile.tag.title.decode('utf-8')+"\"\n")
				notFoundFiles = open("NotFoundLyrics.txt", "a")
				notFoundFiles.write(audiofile.tag.artist.decode('utf-8') + ' - ' + audiofile.tag.title.decode('utf-8'))
