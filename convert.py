import sys
import os

def reftoraw(refdir,rawfile):
    """
    take the ref directory of an xva file and create a raw importable file
    """
    blocksize=1024*1024
    notification=float(2**30) # 2**30=GB
    numfiles=0
    for dirobj in os.listdir(refdir):
        try:
            numfile=int(dirobj)
        except ValueError as TypeError:
            numfile=0;
        if numfile>numfiles:
            numfiles=numfile
    print('last file         :',numfiles+1)
    print('disk image size   :',(numfiles+1)/1024,'GB')
    if os.path.isdir(refdir):
        # This may cause problems in Windows!
        if refdir[-1]!='/':
            refdir+='/'
        if not os.path.exists(rawfile):
            try:
                filenum=0
                noticetick=notification/(2**30)
                print('\nRW notification every: '+str(noticetick)+'GB')
                notification=notification/blocksize
                dest=open(rawfile,'wb')
                sys.stdout.write('Converting: ')
                while filenum<=numfiles:
                    if (filenum+1)%notification==0:
                        sys.stdout.write(str(((filenum+1)/notification)*noticetick)+'GBr')
                    filename=str(filenum)
                    while len(filename)<8:
                        filename='0'+filename
                    if os.path.exists(refdir+filename):
                        source=open(refdir+filename,'rb')
                        while True:
                            data=source.read(blocksize)
                            if len(data)==0:
                                """source.close()"""
                                #sys.stdout.write(str('\nProcessing '+refdir+filename+'...'))
                                break # EOF
                            dest.write(data)
                    else:
                        #print '\n'+refdir+filename+' not found, skipping...'
                        dest.seek(blocksize,1)
                    if (filenum+1)%notification==0:
                        sys.stdout.write('w ')
                    sys.stdout.flush()
                    filenum+=1
                print('\nSuccessful convert')
            finally:
                try:
                    dest.close()
                    """source.close()"""
                finally:
                    print()
        else:
            print('ERROR: rawfile '+rawfile+' exists')
    else:
        print('ERROR: refdir '+refdir+' does not exist')

reftoraw(sys.argv[1],sys.argv[2])
