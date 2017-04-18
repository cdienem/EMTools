#!/bin/bash

# this is rather slow
# consider the python solution

while read line; do if ! $(echo "$line" | grep -q "TER"); then echo $line >> out.pdb; fi; done < 5fz5_GAT1_TFIIE_homology.pdb
