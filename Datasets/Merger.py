
######## Merge data with Director #########
import sys
file_name = "./LIST/directors.list.tsv"

d = {}
with open(file_name) as f:
	for line in f:
		row = line.split("\t")
		index_of_pare = row[len(row)-2].index('(')
		key = row[len(row)-2][:index_of_pare-1]
		name = row[0]
		for i in range(1,len(row)-2):
			name = name + " " + row[i]
		d[key] = name

#f1 = open(file_name)
f_temp = open("./TSV/temp-after-directer.tsv", "w")
f2 = open("./TSV/movie_data.tsv")
#f2 = open("./LIST/directors.list.tsv")
for line2 in f2:
	row2 = line2.split("\t")
	movie_name = row2[1][1:-1]
	#print(line2)
	if movie_name in d:
		#print("found!")
		writemp = line2[:-2] + "\t" + d[movie_name]
		f_temp.write(writemp+"\n")
	else:
		f_temp.write(line2[:-2] + "\tNA"+"\n")
f2.close()



####### Merge with Writers  #########
file_name = "./LIST/writers.list.tsv"

d = {}
with open(file_name) as f:
	for line in f:
		row = line.split("\t")
		index_of_pare = row[len(row)-4].index('(')
		key = row[len(row)-4][:index_of_pare-1]
		name = row[0]
		for i in range(1,len(row)-4):
			name = name + " " + row[i]
		d[key] = name

f2 = open("./TSV/temp-after-directer.tsv")
f_temp = open("./TSV/temp-after-writers.tsv", "w")

for line2 in f2:
	row2 = line2.split("\t")
	movie_name = row2[1][1:-1]
	if movie_name in d:
		writemp = line2[:-2] + "\t" + d[movie_name]
		f_temp.write(writemp+"\n")
	else:
		f_temp.write(line2[:-2] + "\tNA"+"\n")
f2.close()
f_temp.close()



####### Merge with Product Company #########
file_name = "./LIST/production-companies.list.tsv"

d = {}
with open(file_name) as f:
	for line in f:
		row = line.split("\t")
		index_of_pare = row[0].index('(')
		key = row[0][:index_of_pare-1]
		name = row[1][:-1]
		d[key] = name


f2 = open("./TSV/temp-after-writers.tsv")
f_temp = open("./TSV/temp-after-prodcompanies.tsv", "w")
for line2 in f2:
	row2 = line2.split("\t")
	movie_name = row2[1][1:-1]
	if movie_name in d:
		writemp = line2[:-1] + "\t" + d[movie_name]
		f_temp.write(writemp+"\n")
	else:
		f_temp.write(line2[:-1] + "\tNA"+"\n")
f2.close()
f_temp.close()


####### Merge with  Language #########
file_name = "./LIST/language.list.tsv"

d = {}
with open(file_name) as f:
	for line in f:
		row = line.split("\t")
		index_of_pare = row[0].index('(')
		key = row[0][:index_of_pare-1]
		name = row[len(row)-1][:-1]
		d[key] = name

f2 = open("./TSV/temp-after-prodcompanies.tsv")
f_temp = open("./TSV/temp-after-language.tsv", "w")
for line2 in f2:
	row2 = line2.split("\t")
	movie_name = row2[1][1:-1]
	if movie_name in d:
		writemp = line2[:-1] + "\t" + d[movie_name]
		f_temp.write(writemp+"\n")
	else:
		f_temp.write(line2[:-1] + "\tNA"+"\n")
f2.close()
f_temp.close()


####### Merge with Actors #########
import sys
file_name = "./LIST/actors.list.tsv"

d = {}
with open(file_name) as f:
	for line in f:
		row = line.split("\t")
		index_of_pare = row[len(row)-4].index('(')
		key = row[len(row)-4][:index_of_pare-1]
		name = row[0]
		for i in range(1,len(row)-4):
			name = name + " " + row[i]
		d[key] = name

f2 = open("./TSV/temp-after-language.tsv")
f_temp = open("./TSV/temp-after-actors.tsv", "w")
for line2 in f2:
	row2 = line2.split("\t")
	movie_name = row2[1][1:-1]
	if movie_name in d:
		writemp = line2[:-1] + "\t" + d[movie_name]
		f_temp.write(writemp+"\n")
	else:
		f_temp.write(line2[:-1] + "\tNA"+"\n")
f2.close()
f_temp.close()

####### Merge with  Actress #########
file_name = "./LIST/actresses.list.tsv"

d = {}
with open(file_name) as f:
	for line in f:
		row = line.split("\t")
		index_of_pare = row[len(row)-4].index('(')
		key = row[len(row)-4][:index_of_pare-1]
		name = row[0]
		for i in range(1,len(row)-4):
			name = name + " " + row[i]
		d[key] = name

f2 = open("./TSV/temp-after-actors.tsv")
f_temp = open("./TSV/Final.tsv", "w")
for line2 in f2:
	row2 = line2.split("\t")
	movie_name = row2[1][1:-1]
	if movie_name in d:
		writemp = line2[:-1] + "\t" + d[movie_name]
		f_temp.write(writemp+"\n")
	else:
		f_temp.write(line2[:-1] + "\tNA"+"\n")
f2.close()
f_temp.close()
