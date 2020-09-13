from os import linesep
from sys import stderr
import re
from enum import Enum,auto,unique

@unique
class CommandMode(Enum):
	main   =auto()
	help   =auto()
	version=auto()
CM=CommandMode

@unique
class multipleMode(Enum):
	none  =auto()
	serial=auto()
	spawn =auto()
	thread=auto()
MM=multipleMode

class data:
	mode=CM.main
	command=[]
	out="inherit"
	err="inherit"
	result="stderr"
	multiple=MM.none

def error(text):
	stderr.write(text+linesep)
	exit(1)

def clean(text):
	text=re.sub(r"(?m)\t+","",text)
	text=re.sub(r"^\n","",text)
	return text

def eq(target,*cans):
	for c in cans:
		if c==target: return True
	return False