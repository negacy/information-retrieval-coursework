'''
CSCI 5417 - programming assignment I
This program produces Inverted Index for docuemnts given in a single file. 
The file is input to the program  and 
terms with theirs postings will be displayed into the screen.
'''

import sys
import re

from collections import defaultdict

def main():
    if len(sys.argv) != 2:
        print 'Usage: ./ass1.py med.all'
    else:
		data = open(sys.argv[1]).readlines()
		docId = ''
		term = defaultdict(list) #a dictionary data structure -- term will be the keys and list of docId i.e. postings will be the values.

		for line in data:
			if line.startswith('.I'):
				docId = int(line.strip('.I').strip())
			elif not line.startswith('.W'):
				termTmp = line.strip().split()
				for word in termTmp:
					nonAlphanumericWord = re.split(r'[^a-zA-Z0-9\-]', word)
					for t in nonAlphanumericWord:
						if t !='': #avoid ''
							if t in term:
								term[t].append(docId)
							else:
								term[t] = [docId]
		for k in sorted(term): #Formatting according to the assignment description. 
			print k + ','+ ','.join(str(i) for i in sorted(set(term[k])))
		
				
if __name__ == "__main__":
    main()

