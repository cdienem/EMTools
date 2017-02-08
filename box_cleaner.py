#!/bin/python
 
############# Box Cleaner Version 20160825_1 ########
# by Chris
 
 
import csv
import os
 
 
# Changer parameters here
# Dimension in x,y of the micrographs in px
X = 3838
Y = 3710
# Dimension of the particle box that should be extracted (in px)
D = 380
 
 
# Note that that EMAN uses a weird way of storing the coordinates.
# It writes x,y for the lower left edge of the box where the very 
# top left corner of the micrograph has coordinates 0,Y
 
# Cleaned .box files are stored as new files with a "rem_" suffix
# Just move the old files somewhere else and rename the new files with
# the terminal command:
#
# rename 'rem_' '' *.box
# 
# If you run the command locally (e.g. on a mac or Ubuntu machine) it should be
#
# rename 's/^rem_//' *.box
 
 
# Don't edit below here
dirs = os.listdir('.')
overall = 0
for file in dirs:
        if file[-4:] == ".box" and file[0:4] != "rem_":
                new = "rem_"+file
                with open(file, "rb") as csvin, open(new, "wb") as csvout:
                        boxreader = csv.reader(csvin, delimiter='\t')
                        boxwriter = csv.writer(csvout, delimiter="\t")
                        counta = 0
                        countb = 0
                        for row in boxreader:
                                x = int(row[0])
                                y = int(row[1])
                                counta = counta +1
                                if x >= 0 and y >= 0 and x+D < X and y+D <= Y:
                                        # add thing to boxwriter
                                        boxwriter.writerow(row)
                                        countb = countb + 1
                        rem = counta-countb
                        overall = overall + rem
                        if rem > 0:
                                print "Removed "+ str(counta-countb) +" particles from " + file
print "Removed " +str(overall)+ " particles in total."


