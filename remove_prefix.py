import sys
import shutil
import time
import re

data_filename=sys.argv[1]

fd = open(data_filename,'rw')
header = fd.readline()

split_header = re.split('\t|\.|\n',header)
column_names = split_header[1:-1:2]
column_names.append("\n")

new_header = "\t".join(column_names)

new_filename = ".".join(["~temp~", str(int(time.time())), data_filename])
fd_new = open(new_filename ,'w')
fd_new.writelines(new_header)


shutil.copyfileobj(fd,fd_new)

fd_new.close()
fd.close()
shutil.move(new_filename,data_filename)


