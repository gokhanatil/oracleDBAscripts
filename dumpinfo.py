#!/usr/bin/python

#---------------------------------------------------------------------
# dumpinfo (C) 2014 Gokhan Atil http://www.gokhanatil.com
#---------------------------------------------------------------------

import struct, binascii, sys

if len(sys.argv) != 2:
    print 'Usage: dumpinfo.py filename'
    exit()


f = open(sys.argv[1], 'rb')

try:
    buffer = f.read(600)

finally:
    f.close()    

magic1 = struct.unpack_from( 'B', buffer, 477 )[0]
magic2 = struct.unpack_from( 'B', buffer, 3 )[0]

print magic1
print magic2

if (magic1==49):
    filevermajor,filevermin = struct.unpack_from( 'BB', buffer )
    year,mon,day,hour,min,sec = struct.unpack_from( 'HBBBBB', buffer, 41 )
    version = struct.unpack_from( '14s', buffer, 477 )[0]
    platform = struct.unpack_from( '30s', buffer, 133 )[0]
    charset = struct.unpack_from( '20s', buffer, 295 )[0]
    blocksize1,blocksize2 = struct.unpack_from( 'BB', buffer, 37 )
    jobname = struct.unpack_from( '40s', buffer, 67 )[0]
    filevernum = struct.unpack_from( 'H', buffer )[0]
    charsetID = struct.unpack_from( 'B', buffer, 40 )[0]
    mastertablepos = struct.unpack_from( 'B', buffer, 57 )[0]
    len1,len2,len3,len4 = struct.unpack_from( 'BBBB', buffer, 62 )
    jguid = struct.unpack_from( '16s', buffer, 15 )[0]

    # fix network byte order
    
    blocksize = blocksize1 * 256 + blocksize2   
    mastertablelen = (len1 * 256 + len2) * 65536 + (len3 * 256 + len4)

    print ' ........Filetype = Datapump dumpfile'
    print ' ......DB Version = ' + version
    print ' File Version Str = ' + str(filevermajor) + '.' + str(filevermin) 
    print ' File Version Num = ' + str(filevernum) 
    print ' ........Job Guid = ' + binascii.hexlify(jguid)
    print ' Master Table Pos = ' + str(mastertablepos) 
    print ' Master Table Len = ' + str(mastertablelen)
    print ' ......Charset ID = ' + str(charsetID)
    print ' ...Creation date = ' + str(day) + '-' + str(mon) + '-' + str(year) + ' ' + str(hour) + ':'+ str(min) + ':'+ str(sec) 
    print ' ........Job Name = ' + jobname
    print ' ........Platform = ' + platform
    print ' ........Language = ' + charset
    print ' .......Blocksize = ' + str(blocksize)
    
elif (magic2 == 69):
    exportdate = struct.unpack_from( '20s', buffer, 108 )[0]
    exportver = struct.unpack_from( '8s', buffer, 11 )[0]
    print ' ........Filetype = Classic Export file'
    print ' ..Export Version = ' + str(exportver)
    print ' .....Direct Path = 0 (Conventional Path)'
    print ' ...Creation date = ' + exportdate

elif (magic2 == 68):
    exportdate = struct.unpack_from( '20s', buffer, 109 )[0]
    exportver = struct.unpack_from( '8s', buffer, 13 )[0]
    print ' ........Filetype = Classic Export file'
    print ' ..Export Version = ' + str(exportver)
    print ' .....Direct Path = 1 (Direct Path)'
    print ' ...Creation date = ' + exportdate

else:
    print ' ..........Error = Unsupported File';

