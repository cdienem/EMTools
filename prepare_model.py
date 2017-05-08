#!/bin/python

# prepares a model pdb for usage with flexem
# flexem requires a stupid format that has a single chain, all atoms in row and no TER

FILE="model3.pdb"

# serialize atom number [7-11] -> 6:11
# serialize chain [22] -> 21:22
# serialize resi [23-26] -> 22:26

atom=1

resi=0
p_resi=0

p_atom=0

p_chain=""

old_pdb = []
new_pdb = []

with open(FILE,"r") as f:
	for line in f:
		if line[0:4] == "ATOM":
			old_pdb.append(line)

# use first chain identifyer
chain=old_pdb[0][21:22]
p_chain=chain

i = 0
while i < len(old_pdb):
	# chop down line into pieces: 
	print "OLD: "+old_pdb[i].replace("\n","")
	new = [old_pdb[i][0:6], #0 Keyword
		old_pdb[i][6:11], #1 atom number
		old_pdb[i][11:21], #2 some shit
		old_pdb[i][21:22], #3 chain
		old_pdb[i][22:26], #4 resi
		old_pdb[i][26:]] #5 rest of the shit
	
	
	#regularize chain and insert TER
	#ATOM   3688  O   LEU A 530      91.237 100.604  85.606  1.00  8.46           O
	#TER    3689      LEU A 530
	
	if new[3] != chain:
		if new[3] != p_chain:
			new_pdb.append("TER   "+(5-len(str(atom)))*" "+str(atom)+"      "+new_pdb[-1][17:20]+" "+chain+(4-len(str(resi)))*" "+str(resi)+"\n")
			atom= atom+1
			resi=resi+1
		p_chain = new[3]
		new[3]=chain

	# put new resi number here
	if int(new[4]) != resi:

		dif = int(new[4])-int(p_resi)
		
		if new[4] != p_resi:
			if dif > 1 and atom > 1 and new_pdb[-1][0:3] != "TER":
				print "make a TER here if not existing"
				new_pdb.append("TER   "+(5-len(str(atom)))*" "+str(atom)+"      "+new_pdb[-1][17:20]+" "+chain+(4-len(str(resi)))*" "+str(resi)+"\n")
				atom= atom+1
			p_resi	= new[4]
			resi = resi+1

		new[4] = (4-len(str(resi)))*" "+str(resi)
		#new[4] = (4-len(str(resi)))*" "+str(resi)+"/"+str(p_resi)
		
	
	# put new atom number here
	new[1] = (5-len(str(atom)))*" "+str(atom)
	atom = atom+1

	new_pdb.append("".join(new))
	i = i+1

new_pdb.append("END")
with open("out.pdb","w") as f:
	f.write("".join(new_pdb))




