#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Dec 15 15:25:23 2022

@author: cpapadopoulos
"""


import sys


strands = {"stringtie" : { '1+-,1-+,2++,2--' : 'rf' ,
                           '1++,1--,2+-,2-+' : 'fr' ,
                           '++,--' : 'fr' , '+-,-+' : 'rf'},

           "trinity"   :  { '1+-,1-+,2++,2--' : 'RF' ,
                            '1++,1--,2+-,2-+' : 'FR' ,
                            '++,--' : None , '+-,-+' : None},

           "featureCounts" : { '1+-,1-+,2++,2--' : '2' ,
                               '1++,1--,2+-,2-+' : '1' ,
                               '++,--' : '1' , '+-,-+' : '2'},

           }


table_file = sys.argv[sys.argv.index("-tab")+1]
method     = sys.argv[sys.argv.index("-tool")+1]

dico = {}
with open(table_file,"r") as f:
    for line in f:
        if line.startswith("This is"):
            data_type = line.split()[2]

        if line.startswith("Fraction of reads explained by"):
            dico[line.split()[5].strip(":").strip('"')] = line.split()[6].strip('"')


if abs(float(list(dico.values())[0]) - float(list(dico.values())[1])) > 0.5:
    strandness = list(dico.keys())[list(dico.values()).index(max(dico.values()))]
else:
    print("There is no strandness")
    exit()

print(strands[method][strandness])
