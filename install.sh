#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'

PATH=$PATH:/usr/local/bin
export PATH

declare -a needed
if ! command -v nmap &> /dev/null
then
	needed+=( nmap )
fi

if ! command -v dnsrecon &> /dev/null
then
	needed+=( dnsrecon )
fi

if ! command -v wfuzz &> /dev/null
then
	needed+=( wfuzz )
fi

if ! command -v wafw00f &> /dev/null
then
	needed+=( wafw00f )
fi

if ! command -v whatweb &> /dev/null
then
	needed+=( whatweb )
fi

if [[ ${#needed[@]} -gt 0 ]]; then
	`sudo apt install ${needed[@]}`
else
	echo "Pre-requisites already installed. Enjoy!"
fi