#!/bin/bash

#abort on error
set -e

function usage
{
    echo "usage: download-xva -h XEN_HOST -i UUID [-n VM_NAME || -d EXPORT_DIR || -h]"
    echo "   ";
    echo "  -x | --xen-host          : XEN Host";
    echo "  -u | --uuid              : VM/Snapshot UUID";
    echo "  -o | --output            : Output file (Default: uuid.xva)";
    echo "  -h | --help              : This message";
}

function parse_args
{
    # positional args
    args=()
    
    # named args
    while [ "$1" != "" ]; do
        case "$1" in
            -x | --xen-host )             xen_host="$2";               shift;;
            -u | --uuid )                 uuid="$2";                   shift;;
            -o | --output )               output="$2";                 shift;;
            -h | --help )                 usage;                       exit;; # quit and show usage
            * )                           args+=("$1")                 # if no match, add it to the positional args
        esac
        shift # move to next kv pair
    done
    
    # restore positional args
    set -- "${args[@]}"
    
    # validate required args
    if [[ -z "${xen_host}" || -z "${uuid}" ]]; then
        echo "Invalid arguments"
        usage
        exit;
    fi
    
    # set defaults
    if [[ -z "$output" ]]; then
        output="${uuid}.xva";
    fi
}


function run
{
    parse_args "$@"
    
    # print options
    echo "#######################################################"
    echo "xen_host    : ${xen_host}"
    echo "uuid        : ${uuid}"
    echo "output      : ${output}"
    echo "#######################################################"
    echo
    
    # read creds
    echo -n "username: "
    read username
    echo -n "password: "
    read -s password
    echo
    echo
    
    # download xva
    curl --fail -o "${output}" "http://${username}:${password}@${xen_host}/export?uuid=${uuid}"
    echo
    echo "curl exit code: $?"
    echo
}


run "$@";
