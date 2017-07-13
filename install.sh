#!/bin/bash
#                                                 INSTALL PREREQUISITES
# echo "Please ensure this script is run as root."
# apt-get install -y build-essential libtool libcurl4-openssl-dev libudev-dev libncurses5-dev autoconf automake git screen uthash-dev libmicrohttpd-dev libevent-dev libusb-1.0-0-dev libusb-dev shellinabox libdb4.8-dev libdb4.8++-dev libminiupnpc-dev libqt4-dev libprotobuf-dev protobuf-compiler libqrencode-dev libboost-all-dev libssl-dev
#                                                     CONFIGURATION
SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )    # Save the script's asbolute path in $SCRIPT_DIR

#rm -rf pfennig   # Could be something there user wants preserved
if [ -e "pfennig" ] then 
	mv pfennig pfennig.old
fi

#                                                     WELCOME SCREEN
echo -e "\n\n\n\n"
echo " - Welcome to the Pfennig Customization script! - "
echo " ----------------------------------------------- "
echo "| HELP  |     #Bitmark@irc.freenode.net         |"
echo " ----------------------------------------------- "
echo -e "\n"
#                                        START GLOBAL SOURCE CODE REPLACEMENTS                                                                                                # Load prefix map, (256bit number mapped to 1-9a-zA-Z)
git clone 'git://github.com/project-bitmark/pfennig.git' # Clone Pfennig from github
read -p "Enter your coin's name [zmark]: " FORK_NAME     # Prompt for the name
[[ ! ${FORK_NAME} ]] && FORK_NAME='zmark'                # Set default value if prompt null
# re-name folder from 'pfennig' to chosen name #dbkeys
mv pfennig ${FORK_NAME}
#cd pfennig && echo $PWD   # Change to Pfennig directory & echo newline
cd ${FORK_NAME} && echo $PWD
grep -rl 'pfennig' | xargs sed -i "s/pfennig/${FORK_NAME}/g"     # Replace pfennig with 'yourcoin'
grep -rl 'Pfennig' | xargs sed -i "s/Pfennig/${FORK_NAME^}/g"    # and Pfennig with 'Yourcoin'
read -p "Enter your currency code [ZMK]: " TICKER                # Prompt for currency code
[[ ! ${TICKER} ]] && TICKER='ZMK'                                # Set default value if prompt null
grep -rl 'PFG' | xargs sed -i "s/PFG/${TICKER}/g"                # Replace 'PFG' with currency code (this is by design)
read -p "Enter your desired P2P port [8388]: " P2P_PORT          # Prompt for P2P port
[[ ! ${P2P_PORT} ]] && P2P_PORT='8388'                           # Set default value if prompt null
grep -rl 'P2PPORT' | xargs sed -i "s/P2PPORT/${P2P_PORT}/g"      # Replace 'P2PPORT' with the P2P_PORT
read -p "Enter your desired RPC port [8387]: " RPC_PORT          # Prompt for RPC port
[[ ! ${RPC_PORT} ]] && RPC_PORT='8387'                           # Set default value if prompt null
grep -rl 'RPCPORT' | xargs sed -i "s/RPCPORT/${RPC_PORT}/g"      # Replace 'RPCPORT' with RPC_PORT
#                                 REPLACEMENTS FINISHED START src/chainparams.cpp EDITS 
cd src                                                           # Change to source directory
read -p "Enter networks fixed seed(s), as a comma separated list of ip addresses. [92.222.25.245, 204.68.122.11, 70.168.53.147]: " SEED_NODES  # Prompt for seed node IP or list thereof
[[ ! ${SEED_NODES} ]] && echo true || echo false
[[ ! ${SEED_NODES} ]] && SEED_NODES='70.168.53.153, 72.220.72.169, 92.222.25.245, 204.68.122.11, 70.168.53.147'
SEED_NODE_LIST=(${SEED_NODES//,/ })                              # Replace commas with spaces then split into array on standard IFS=" "
for IPV4_ADDRESS in ${SEED_NODE_LIST[*]}; do                     # Iterate over desired seed node ipv4 addresses
	echo $IPV4_ADDRESS
	IP_SPACE_DELIM=${IPV4_ADDRESS//./ }                      # Strip dots for conversion to hex
	HEX_ENCODED_ADDRESSES="${HEX_ENCODED_ADDRESSES}0x$(printf '%02X' ${IP_SPACE_DELIM}), "                         # Array of hex encoded node addresses.
done
sed -i "24s/.*/    ${HEX_ENCODED_ADDRESSES} \/\/ Edited via script/" chainparams.cpp                               # Insert seed nodes into code

read -p "Initial block subsidy. [20]: " SUBSIDIARY               # Prompt for initial block subsidy
[[ ! ${SUBSIDIARY} ]] && SUBSIDIARY='10' || SUBSIDIARY=$((SUBSIDIARY/2))                                # Set default value if prompt null
sed -i "1215s/.*/    int64_t nHalfReward = ${SUBSIDIARY} * COIN; \/\/ Edited via script/" main.cpp            # Insert half life into code

read -p "Initial difficulty. [21]: " INIT_DIFF                                                         # Prompt for subsidiary half life
[[ ! ${INIT_DIFF} ]] && INIT_DIFF='21'                               # Set default value if prompt null
sed -i "40s/.*/        bnProofOfWorkLimit = CBigNum(~uint256(0) >> ${INIT_DIFF}); \/\/ Edited via script/" chainparams.cpp            # Insert half life into code


read -p "Enter network's subsidiary half life, in blocks. [788000]: " HALF_LIFE                                    # Prompt for subsidiary half life
[[ ! ${HALF_LIFE} ]] && HALF_LIFE='788000'                                                                         # Set default value if prompt null
sed -i "41s/.*/        nSubsidyHalvingInterval = ${HALF_LIFE}; \/\/ Edited via script/" chainparams.cpp            # Insert half life into code
read -p "Enter genesis block message [Insight for the benefit of all.]: " GENESIS_BLOCK_MSG                        # Prompt for genesis block message
[[ ! ${GENESIS_BLOCK_MSG} ]] && GENESIS_BLOCK_MSG='"Insight for the benefit of all."'                              # Set default value if prompt null
sed -i "44s/.*/        const char* pszTimestamp = ${GENESIS_BLOCK_MSG}; \/\/ Edited via script/" chainparams.cpp   # Insert half life into code

# dbkeys
time_now=$(date +"%s")
echo "The time now (unix format: seconds after Jan. 1, 1970) is: "$time_now
read -p "Enter your genesis block time - When are you launching the coin ? (in Unix timestamp format) ["$time_now"]:  GENESIS_BLOCK_TIME"                         # Prompt for genesis block message
[[ ! ${GENESIS_BLOCK_TIME} ]] && GENESIS_BLOCK_TIME=$time_now 	#1405274410'                          #Set default value if prompt null to time now.
sed -i "55s/.*/        genesis.nTime    = ${GENESIS_BLOCK_TIME}; \/\/ Edited via script/" chainparams.cpp          # Insert half life into code
read -p 'Enter networks dns seeder/backup, comma separated list (feel free to ignore these) ["zmark.org", "seed.zmark.org"]: ' DNS_SEED_NODES
[[ ! ${DNS_SEED_NODES} ]] && DNS_SEED_NODES='"zmark.org", "seed.zmark.org"'                    # Line above prompts dns seeders, this line sets default
sed -i "64s/.*/        vSeeds.push_back(CDNSSeedData(${DNS_SEED_NODES})); \/\/ Edited via script/" chainparams.cpp # Insert seed nodes into code
#                                             OAD & CONFIGURE PREFIX MAP
. ${SCRIPT_DIR}/prefix.cnf # Load the prefix map from file prefix.cnf (LOADS INTO VARIABLE $x)
function auto_prefix() {
  echo ${x[${1}]}
}

echo -e "\nWe are about to configure your coin's address prefix's, would you like to enter them manually (a number between 0-222)\n"
echo "or would you rather directly enter your prefered characters automatically. (an alphanumeric character)"
read -p "Enter 1 for auto or 0 for manual. [1]: " PREFIX_INPUT_MODE
[[ ! ${PREFIX_INPUT_MODE} ]] && PREFIX_INPUT_MODE='1'

read -p "Enter your PUBLIC key prefix [z/143]: " PUBLIC_PREFIX                         # Prompt for genesis block message
DESIRED_PUB_PREFIX=${PUBLIC_PREFIX}
if [[ ( ! ${PUBLIC_PREFIX} ) ]]; then
	[[ ${PREFIX_INPUT_MODE} = 1 ]] && PUBLIC_PREFIX='z' || PUBLIC_PREFIX='143'
fi
[[ ${PREFIX_INPUT_MODE} = '1' ]] && PUBLIC_PREFIX=$(auto_prefix ${PUBLIC_PREFIX})
echo "Will use "$PUBLIC_PREFIX" for Public Prefix"   # Give confirmation of chosen prefix & its code
sed -i "66s/.*/        base58Prefixes[PUBKEY_ADDRESS] = list_of(${PUBLIC_PREFIX}); \/\/ Edited via script - ${DESIRED_PUB_PREFIX}/" chainparams.cpp          # Insert half life into code

PRIVATE_PREFIX=$((${PUBLIC_PREFIX}+128))
sed -i "68s/.*/        base58Prefixes[SECRET_KEY]     = list_of(${PRIVATE_PREFIX}); \/\/ Edited via script - PUBKEY_PREFIX + 128/" chainparams.cpp          # Insert half life into code

echo -e "\nAUTOMATICALLY CONFIGURING YOUR TESTNET SETTINGS WITH RPCPORT=1${RPC_PORT}, P2PPORT=1${P2P_PORT}...\n"
sed -i "117s/.*/        nDefaultPort = 1${P2P_PORT}; \/\/ Edited via script/" chainparams.cpp          # Testnet standard P2P port
sed -i "118s/.*/        nRPCPort     = 1${RPC_PORT}; \/\/ Edited via script/" chainparams.cpp          # Testnet RPC port

read -p 'Configure difficulty retarget time, in seconds (default is 1 day) [86400]: ' DIFF_RETARGET_TIME_IN_SECONDS
[[ ! ${DIFF_RETARGET_TIME_IN_SECONDS} ]] && DIFF_RETARGET_TIME_IN_SECONDS='86400'                    # Line above prompts for retarget time,  this line sets default
sed -i "1230s/.*/ static const int64_t nTargetTimespan = ${DIFF_RETARGET_TIME_IN_SECONDS}; \/\/ Edited via script - values unit is seconds/" main.cpp # Insert seed nodes into code

echo "The inter-block average delay time or \"block time\" is only a target which is achieved in the average. (Finding hashes to validate blocks is a Poisson random process.)"

# dbkeys
# Error checking: 
#    Strongly warn user if block time is <12s (the experimentally determined p2p internet data propagation delay; a shorter delay only makes sense in experimental LAN setups) 
#     Advise user that block times less than 2 minutes (120s) results in more block chain forking
read -p 'Configure "block time", in seconds (default is 2 mins) [120]: ' BLOCK_TIME_IN_SECONDS
[[ ! ${BLOCK_TIME_IN_SECONDS} ]] && BLOCK_TIME_IN_SECONDS='120'                    # Line above prompts dns seeders, this line sets default
sed -i "1231s/.*/ static const int64_t nTargetSpacing = ${BLOCK_TIME_IN_SECONDS}; \/\/ Edited via script - values unit is seconds/" main.cpp # Insert seed nodes into code

echo -e "\nYOUR NETWORK WILL RE-TARGET THE DIFFICULTY EVERY $((${DIFF_RETARGET_TIME_IN_SECONDS}/${BLOCK_TIME_IN_SECONDS})) BLOCKS \n"

echo
echo Done ! 
# Might want to print summary of coin characteristics here.
