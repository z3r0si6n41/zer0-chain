#!/bin/bash

cat << EOF

         .d8888b.           .d8888b.                  888               d8b          
        d88P  Y88b         d88P  Y88b                 888               Y8P          
             .d88P         888    888                 888                            
88888888    8888"  888d888 888    888         .d8888b 88888b.   8888b.  888 88888b.  
   d88P      "Y8b. 888P"   888    888        d88P"    888 "88b     "88b 888 888 "88b 
  d88P  888    888 888     888    888 888888 888      888  888 .d888888 888 888  888 
 d88P   Y88b  d88P 888     Y88b  d88P        Y88b.    888  888 888  888 888 888  888 
88888888 "Y8888P"  888      "Y8888P"          "Y8888P 888  888 "Y888888 888 888  888 
                                                                                     

Version: 0.0.1

By @z3r0si6n41
I'm not responsible for what you do with this software. ;)
EOF

SHOW_HELP=0
FULL_RECON=1
DNS_RECON=0
TECH_RECON=0
CMS_TYPE="Unknown"
PORT_RECON=0
VULN_RECON=0
SKIP_DNS=0
SKIP_TECH=0
SKIP_PORT=0
SKIP_VULN=0
SAVE_FILE=0
TIMESTAMP="$(date +%s)"
FILENAME="/tmp/zero-chain-${TIMESTAMP}.txt"
TARGET=""
SCAN_TYPE="FULL"

basic_usage () {
	echo << EOF
Usage: ./zero-chain [options] <target>
[Options]
Note: Full scan mode is enabled by default.

General:
  -h			Display this help screen.
  --help		Display extended help.
Scan:
  -f, --full		Extensive extended scan of target.
  -d, --dns		DNS scan of target.
  -t, --tech		Technologies scan of target.
  -ps, --port-scan	Port scan
  -vs, --vuln-scan	Vulnerability scan
EOF
	exit
}

extended_usage () {
	echo << EOF
Usage: ./zero-chain [options] <target>
[Options]
Note: Full scan mode is enabled by default.

General:
  -h			Display this help screen.
  --help		Display extended help.
Scan:
  -f, --full		Extensive extended scan of target.
  -d, --dns		DNS scan of target.
  -t, --tech		Technologies scan of target.
  -ps, --port-scan	Port scan
  -vs, --vuln-scan	Vulnerability scan
  -sd, --skip-dns	Skip the DNS scan. Used in conjunction with -f/--full.
  -st, --skip-tech	Skip technology scan. Used in conjunction with -f/--full.
  -sp, --skip-ports	Skip port scan. Used in conjunction with -f/--full.
  -sv, --skip-vuln	Skip vulnerability scan. Used in conjunction with -f/--full.
Output:
  -o, --output <file>	Output all data to the specified file.
EOF
	exit
}

for arg in "$@"
do
	case $arg in
		-h)
			basic_usage
		;;
		--help)
			extended_usage
		;;
		-w|--waf)
			shift
			WAF_SCAN=1
			FULL_RECON=0
		;;
		-f|--full)
			shift
			FULL_RECON=1
		;;
		-d|--dns)
			shift
			DNS_RECON=1
			FULL_RECON=0
		;;
		-t|--tech)
			shift
			TECH_RECON=1
			FULL_RECON=0
		;;
		-ps|--port-scan)
			shift
			PORT_RECON=1
			FULL_RECON=0
		;;
		-vs|--vuln-scan)
			shift
			VULN_RECON=1
			FULL_RECON=0
		;;
		-sd|--skip-dns)
			shift
			SKIP_DNS=1
		;;
		-st|--skip-tech)
			shift
			SKIP_TECH=1
		;;
		-sp|--skip-ports)
			shift
			SKIP_PORT=1
		;;
		-sv|--skip-vuln)
			shift
			SKIP_VULN=1
		;;
		-o|--output)
			shift
			SAVE_FILE=1
			FILENAME="$2"
			shift
		;;
		*)
			TARGET="$1"
	esac
done

if [[ $TARGET == "" ]]; then
	echo "You must specify a target."
	basic_usage
fi

IFS=':'
read -a hostarr <<< "$TARGET"

PROTO="${hostarr[0]}://"
HOST="${hostarr[1]:2}"
FQDN="${PROTO}${HOST}"

if [[ $WAF_RECON == 1 ]]; then
	SCAN_TYPE="WAF"
fi
if [[ $DNS_RECON == 1 ]]; then
	SCAN_TYPE="DNS"
fi
if [[ $TECH_RECON == 1 ]]; then
	SCAN_TYPE="TECH"
fi
if [[ $PORT_RECON == 1 ]]; then
	SCAN_TYPE="PORT"
fi
if [[ ${VULN_RECON} == 1 ]]; then
	SCAN_TYPE="VULN"
fi

if [[ ${SAVE_FILE} == 1 ]]; then
	touch $FILENAME
fi

echo
echo "-------------------------------------------------"
echo "# TARGET: ${FQDN}"
echo "# SCAN TYPE: ${SCAN_TYPE}"
echo "-------------------------------------------------"
echo

if [[ $FULL_RECON == 1 || $WAF_RECON == 1 ]]; then
	if [[ ! $SKIP_WAF == 1 ]]; then
		echo
		echo "=========== WAF SCAN ==========="
		echo
		if [[ $SAVE_FILE == 1 ]]; then
			wafw00f "${FQDN}" | tee -a ${FILENAME}
		else
			wafw00f "${FQDN}"
		fi
	fi
fi

if [[ $FULL_RECON == 1 || $DNS_RECON == 1 ]]; then
	if [[ ! $SKIP_DNS == 1 ]]; then
		echo
		echo "=========== DNS SCAN ==========="
		echo
		if [[ $SAVE_FILE == 1 ]]; then
			dnsrecon -d "${HOST}" -as | tee -a ${FILENAME}
		else
			dnsrecon -d "${HOST}" -as
		fi
	fi
fi

if [[ $FULL_RECON == 1 || $TECH_RECON == 1 ]]; then
	if [[ ! $SKIP_TECH == 1 ]]; then
		echo
		echo "=========== TECH SCAN ==========="
		echo
		if [[ $SAVE_FILE == 1 ]]; then
			whatweb "${FQDN}" | tee -a ${FILENAME}
		else
			whatweb "${FQDN}"
		fi
	fi
fi

if [[ $FULL_RECON == 1 || $VULN_RECON == 1 || $PORT_RECON == 1 ]]; then
	if [[ $FULL_RECON == 1 || $VULN_RECON == 1 ]]; then
		echo
		echo "=========== VULN SCAN ==========="
		echo
		if [[ $SAVE_FILE == 1 ]]; then
			nmap -vvv -A "${HOST}" | tee -a ${FILENAME}
		else
			nmap -vvv -A "${HOST}"
		fi
	fi
	if [[ $PORT_RECON == 1 ]]; then
		echo
		echo "=========== PORT SCAN ==========="
		echo
		if [[ $SAVE_FILE == 1 ]]; then
			nmap -vvv -sV "${HOST}" | tee -a ${FILENAME}
		else
			nmap -vvv -sV "${HOST}"
		fi
	fi
fi

exit
