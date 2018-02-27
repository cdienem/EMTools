#!/bin/python


# The PDB likes HETATM at a specific place. Also kick out TERs that are not at the end of a chain.
# To be extended by more features like HELIX assignements etc.
# Removes errant TERs for PDB, puts HETATOMS to the back

# takes two arguments for input and output file

import sys

ifile = []

with open(sys.argv[1], "rb") as infile:
	for line in infile:
		ifile.append(line)


ofile = []

hetatom = []		

# Removes TERs
for card in ifile:
	if card[0:3] != "TER" and card[0:6] != "HETATM":
		ofile.append(card)
	
	if card[0:6] == "HETATM":
		hetatom.append(card)

# recovers the TERs where it is needed
terfile = []
i = 0
while i < len(ofile)-1:
	a = ofile[i][21:22]
	b = ofile[i+1][21:22]
	if a != b:
		print "Hey: "+a+ "/"+b
		terfile.append(ofile[i])
		terfile.append("TER\n")
	else:
		terfile.append(ofile[i])
	i = i+1


oo = terfile + hetatom + ["END"]
#print oo

with open(sys.argv[2],"w+") as outfile:
	for line in oo:		
		outfile.write(str(line))
