#!/bin/python

import sys
with open(sys.argv[1], "rb") as infile, open("no_TER.pdb","w+") as outfile:
	for line in infile:
		# was there a terminator?	
		if line[0:3] != "TER":
			outfile.write(line)
