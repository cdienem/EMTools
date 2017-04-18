#!/bin/python

import sys
prev = "empty"
with open(sys.argv[1], "rb") as infile, open("no_TER.pdb","w+") as outfile:
	#lines=sum(1 for l in infile)
	for line in infile:
		# was there a terminator?	
		if prev[0:3] == "TER":
			# current chain the same as previous and not a heteroatom linke zinc?
			if prev[21:22] == line[21:22] and line[0:3] != "HET":
				print "Removed errant TER in chain "+prev[21:22]+"."
			else:
				outfile.write(prev)
		else:
			outfile.write(prev)
		
		prev = line
