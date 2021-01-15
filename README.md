# xva-convert

Scripts to export and convert XVA Virtual Machine images to qcow2 or img(raw) images.

## How to use

### Find VM/Snapshot UUID

```bash
# ssh into xen host
$ ssh xen.example.com
# list vms, find vm id that needs to be exported
$ xe vm-list
uuid ( RO)           : 5675265a-bdb4-b3d2-05dd-1d03caa0af38
     name-label ( RW): test-store4
    power-state ( RO): halted

uuid ( RO)           : 3d7eb6b9-f3ad-dbcd-4034-3c44829e027f
     name-label ( RW): www1
    power-state ( RO): running

uuid ( RO)           : 5ab706f0-fec1-2f87-7966-22e9797d5dd9
     name-label ( RW): nfs_1
    power-state ( RO): halted
# xe snapshot-list snapshot-of=<VM_UUID>
$ xe snapshot-list snapshot-of=6d834684-f97e-0488-1f76-70bf72df34ac # find snapshot of a vm
uuid ( RO)                : 7f85624c-174e-33fc-5ab6-f8070b8c8f35
          name-label ( RW): export-snapshot
    name-description ( RW):
# if exporting a vm, shut it down
$ xe vm-shutdown uuid=<uuid> force=true
# to take a new snapshot use this
$ xe vm-snapshot vm=<uuid> new-name-label=<vm_snapshot_name>
```

### Exporting `xva`

#### Using download script

```bash
$ xva-convert/download-xva.sh -h
usage: download-xva -x XEN_HOST -u UUID [ -o OUTPUT || -h]

  -x | --xen-host          : XEN Host
  -u | --uuid              : VM/Snapshot UUID
  -o | --output            : Output file (Default: uuid.xva)
  -h | --help              : This message
# xva-convert/download-xva.sh -x XEN_HOST -u VM_UUID/SNAPSHOT_UUID -o XVA_FILE
$ xva-convert/download-xva.sh -x xen.example.com -u 5ab706f0-fec1-2f87-7966-22e9797d5dd9 -o nfs_1.xva
#######################################################
xen_host    : xen.example.com
uuid        : 5ab706f0-fec1-2f87-7966-22e9797d5dd9
output      : nfs_1.xva
#######################################################

username: bharat
password:

  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 3253M    0 3253M    0     0  12.0M      0 --:--:--  0:04:31 --:--:--  274k

curl exit code: 0

```

#### Using `xe` cli

```bash
xe vm-export vm=<VM_UUID/SNAPSHOT_UUID> filename=vm.xva
```

### `xva` ➡ `qcow2`

```bash
$ xva-convert/xva-convert.sh --help
Please run as root/sudo
$ sudo xva-convert/xva-convert.sh --help
usage: xva-convert -f image_format -x xva_file [-o OUTPUT || -h]

  -x | --xva-file          : XVA file
  -f | --image-format      : img / qcow2
  -o | --output            : output image path
  -h | --help              : This message
# sudo xva-convert/xva-convert.sh -x XVA_FILE -f FORMAT
$ sudo xva-convert/xva-convert.sh -x nfs_1.xva -f qcow2
#######################################################
xva_file     : nfs_1.xva
image_format : qcow2
output       : /home/user/nfs_1.qcow2
#######################################################

Extracting XVA ...
3.18GiB 0:00:06 [ 539MiB/s] [=====================================================================================================>] 100%

Converting to raw ...
.xen_convert_tmp/Ref:140
last file         : 76812
disk image size   : 75.01171875 GB

RW notification every: 1.0GB
Converting: 1.0GBrw 2.0GBrw 3.0GBrw 4.0GBrw 5.0GBrw 6.0GBrw 7.0GBrw 8.0GBrw 9.0GBrw 10.0GBrw 11.0GBrw 12.0GBrw 13.0GBrw 14.0GBrw 15.0GBrw 16.0GBrw 17.0GBrw 18.0GBrw 19.0GBrw 20.0GBrw 21.0GBrw 22.0GBrw 23.0GBrw 24.0GBrw 25.0GBrw 26.0GBrw 27.0GBrw 28.0GBrw 29.0GBrw 30.0GBrw 31.0GBrw 32.0GBrw 33.0GBrw 34.0GBrw 35.0GBrw 36.0GBrw 37.0GBrw 38.0GBrw 39.0GBrw 40.0GBrw 41.0GBrw 42.0GBrw 43.0GBrw 44.0GBrw 45.0GBrw 46.0GBrw 47.0GBrw 48.0GBrw 49.0GBrw 50.0GBrw 51.0GBrw 52.0GBrw 53.0GBrw 54.0GBrw 55.0GBrw 56.0GBrw 57.0GBrw 58.0GBrw 59.0GBrw 60.0GBrw 61.0GBrw 62.0GBrw 63.0GBrw 64.0GBrw 65.0GBrw 66.0GBrw
 67.0GBrw 68.0GBrw 69.0GBrw 70.0GBrw 71.0GBrw 72.0GBrw 73.0GBrw 74.0GBrw 75.0GBrw
Successful convert


Converting to qcow2
    (100.00/100%)

image: /home/user/nfs_1.qcow2
file format: qcow2
virtual size: 75 GiB (80530636800 bytes)
disk size: 2.95 GiB
cluster_size: 65536
Format specific information:
    compat: 1.1
    compression type: zlib
    lazy refcounts: false
    refcount bits: 16
    corrupt: false

```
