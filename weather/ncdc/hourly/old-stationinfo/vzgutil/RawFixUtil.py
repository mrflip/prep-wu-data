

def fixForSQL(f):
	"""Converts empty string fields to NULL"""
	#if (f == ''): 		return 'NULL'
	if (f == None): 	return 'NULL'
	if (f == True): 	return 1
	if (f == False): 	return 0
	else:				return f 
	