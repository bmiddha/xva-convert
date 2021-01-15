#!/bin/bash

#abort on error
set -e

if [ "$EUID" -ne 0 ]
then echo "Please run as root/sudo"
    exit
fi

function usage
{
    echo "usage: xva-convert -f image_format -x xva_file [-o || -h]"
    echo "   ";
    echo "  -x | --xva-file          : XVA file";
    echo "  -f | --image-format      : img / qcow2";
    echo "  -o | --output            : output image path";
    echo "  -h | --help              : This message";
}

function parse_args
{
    # positional args
    args=()
    
    # named args
    while [ "$1" != "" ]; do
        case "$1" in
            -x | --xva-file )             xva_file="$2";               shift;;
            -f | --image-format )         image_format="$2";           shift;;
            -o | --output )               output="$2";                 shift;;
            -h | --help )                 usage;                       exit;; # quit and show usage
            * )                           args+=("$1")                 # if no match, add it to the positional args
        esac
        shift # move to next kv pair
    done
    
    # restore positional args
    set -- "${args[@]}"
    
    # validate required args
    if [[ -z "${image_format}" || -z "${xva_file}" ]]; then
        echo "Invalid arguments"
        usage
        exit;
    fi
    if [[ "${image_format}" != "qcow2" && "${image_format}" != "img" ]];then
        echo "Invalid arguments"
        usage
        exit
    fi
    
    # set defaults
    if [[ -z "$output" ]]; then
        basename=$(basename $xva_file)
        output="$(pwd)/${basename%.*}.${image_format}"
    fi
}


function run
{
    parse_args "$@"
    
    # print options
    echo "#######################################################"
    echo "xva_file     : ${xva_file}"
    echo "image_format : ${image_format}"
    echo "output       : ${output}"
    echo "#######################################################"
    echo
    
    script_dir=$(dirname $0)
    temp_dir=.xen_convert_tmp
    # extract xva
    echo "Extracting XVA ..."
    mkdir $temp_dir
    pv $xva_file | tar xf - -C $temp_dir
    echo
    
    disk_ref=$(find $temp_dir/* -type d | grep 'Ref:' | head -n 1)
    
    if [[ "${image_format}" == "qcow2" ]];then
        # convert to raw
        echo "Converting to raw ..."
        echo $disk_ref
        python3 $script_dir/convert.py "${disk_ref}" "$temp_dir/raw.img"
        echo
        
        # convert to qcow2
        echo "Converting to qcow2"
        qemu-img convert -p -f raw -O qcow2 "$temp_dir/raw.img" $output
        echo
        
    fi
    
    if [[ "${image_format}" == "raw" ]];then
        # convert to raw
        echo "Converting to raw ..."
        python xenmigrate.py -convert="${disk_ref}" $output
        echo
    fi
    
    qemu-img info $output
    rm -rf $temp_dir
    echo
    
}


run "$@";
