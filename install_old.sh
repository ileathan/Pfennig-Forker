SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )                                                                                                        # Save the scripts absolute path in $SCRIPT_DIR
rm -rf pfennig                                                                                                                                                      # Make sure pfennig isnt already here
echo -e "\n\n\n\n"                                                                                                                                                  #
echo " -- Welcome to Bitmarks Pfennig clone script! -- "                                                                                                            #
echo " ----------------------------------------------- "                                                                                                            #
echo "| HELP  |     #Bitmark@irc.freenode.net         |"                                                                                                            #
echo " ----------------------------------------------- "                                                                                                            #
echo -e "\n"                                                                                                                                                        #
#                                                                                                                                                                   # START GLOBAL SOURCE CODE REPLACEMENTS                                                   
git clone 'git://github.com/project-bitmark/pfennig.git'                                                                                                            # Clone Pfennig from github
cd pfennig &&                                                                                                                                                       # Change to Pfennig directory & echo newline
read -p "Enter your forks name [zmark]: " FORK_NAME                                                                                                                 # Prompt for the name
[[ ! ${FORK_NAME} ]] && FORK_NAME='zmark'                                                                                                                           # Set default value if prompt null
grep -rl 'pfennig' | xargs sed -i "s/pfennig/${FORK_NAME}/g"                                                                                                        # Replace pfennig with 'yourcoin'
grep -rl 'Pfennig' | xargs sed -i "s/Pfennig/${FORK_NAME^}/g"                                                                                                       # and Pfennig with 'Yourcoin'
read -p "Enter your currency code [ZMK]: " TICKER                                                                                                                   # Prompt for currency code
[[ ! ${TICKER} ]] && TICKER='ZMK      '                                                                                                                             # Set default value if prompt null
grep -rl 'PFG' | xargs sed -i "s/PFG/${TICKER}/g"                                                                                                                   # Replace 'PFG' with currency code (this is by design)
read -p "Enter your desired P2P port [8388]: " P2P_PORT                                                                                                             # Prompt for P2P port
[[ ! ${P2P_PORT} ]] && P2P_PORT='8388'                                                                                                                              # Set default value if prompt null
grep -rl 'P2PPORT' | xargs sed -i "s/P2PPORT/${P2P_PORT}/g"                                                                                                         # Replace 'P2PPORT' with the P2P_PORT
read -p "Enter your desired RPC port [8387]: " RPC_PORT                                                                                                             # Prompt for RPC port
[[ ! ${RPC_PORT} ]] && RPC_PORT='8387'                                                                                                                              # Set default value if prompt null
grep -rl 'RPCPORT' | xargs sed -i "s/RPCPORT/${RPC_PORT}/g"                                                                                                         # Replace 'RPCPORT' with RPC_PORT
#                                                                                                                                                                   # REPLACEMENTS FINISHED START src/chainparams.cpp EDITS 
cd src                                                                                                                                                              # Change to source directory
read -p "Enter networks fixed seed(s) [92.222.25.245, 204.68.122.11, 70.168.53.147]: " SEED_NODES                                                                   # Prompt for seed node IP or list thereof
[[ ! ${SEED_NODES} ]] && SEED_NODES='70.168.53.153, 72.220.72.169, 92.222.25.245, 204.68.122.11, 70.168.53.147'                                                     # If prompt defaulted set default values
SEED_NODE_LIST=(${SEED_NODES//,/ })                                                                                                                                 # Replace commas with spaces then split into array on standard IFS=" "
for IPV4_ADDRESS in ${SEED_NODE_LIST[*]}; do                                                                                                                        # Iterate over desired seed node ipv4 addresses
IP_SPACE_DELIM=${IPV4_ADDRESS//./ }                                                                                                                                 # Strip dots for conversion to hex
HEX_ENCODED_ADDRESSES="${HEX_ENCODED_ADDRESSES}0x$(printf '%02X' ${IP_SPACE_DELIM}), "                                                                              # Array of hex encoded node addresses.
done                                                                                                                                                                #
sed -i "24s/.*/    ${HEX_ENCODED_ADDRESSES} \/\/ Edited via script/" chainparams.cpp                                                                                # Insert seed nodes into code
read -p "Initial block subsidiary. [20]: " SUBSIDIARY                                                                                                               # Prompt for subsidiary half life
[[ ! ${SUBSIDIARY} ]] && SUBSIDIARY='10' || SUBSIDIARY=$((SUBSIDIARY/2))                                                                                            # Set default value if prompt null
sed -i "1215s/.*/    int64_t nHalfReward = ${SUBSIDIARY} * COIN; \/\/ Edited via script/" main.cpp                                                                  # Insert half life into code
read -p "Initial difficulty. [21]: " INIT_DIFF                                                                                                                      # Prompt for subsidiary half life
[[ ! ${INIT_DIFF} ]] && INIT_DIFF='21'                                                                                                                              # Set default value if prompt null
sed -i "40s/.*/        bnProofOfWorkLimit = CBigNum(~uint256(0) >> ${INIT_DIFF}); \/\/ Edited via script/" chainparams.cpp                                          # Insert half life into code
read -p "Enter networks subsidiary half life. [788000]: " HALF_LIFE                                                                                                 # Prompt for subsidiary half life
[[ ! ${HALF_LIFE} ]] && HALF_LIFE='788000'                                                                                                                          # Set default value if prompt null
sed -i "41s/.*/        nSubsidyHalvingInterval = ${HALF_LIFE}; \/\/ Edited via script/" chainparams.cpp                                                             # Insert half life into code
read -p "Enter genesis block message [Insight for the benefit of all.]: " GENESIS_BLOCK_MSG                                                                         # Prompt for genesis block message
[[ ! ${GENESIS_BLOCK_MSG} ]] && GENESIS_BLOCK_MSG='"Insight for the benefit of all."'                                                                               # Set default value if prompt null
sed -i "44s/.*/        const char* pszTimestamp = ${GENESIS_BLOCK_MSG}; \/\/ Edited via script/" chainparams.cpp                                                    # Insert half life into code
read -p "Enter your genesis block time (in unix timestamp format) [1405274410]: " GENESIS_BLOCK_TIME                                                                # Prompt for genesis block message
[[ ! ${GENESIS_BLOCK_TIME} ]] && GENESIS_BLOCK_TIME='1405274410'                                                                                                    # Set default value if prompt null -btm: 1405274442
sed -i "55s/.*/        genesis.nTime    = ${GENESIS_BLOCK_TIME}; \/\/ Edited via script/" chainparams.cpp                                                           # Insert half life into code
read -p 'Enter networks dns seeder/backup (feel free to ignore these) ["zmark.com", "seed.zmark.org"]: ' DNS_SEED_NODES                                             # Prompt fr dns seeds
[[ ! ${DNS_SEED_NODES} ]] && DNS_SEED_NODES='"zmark.com", "seed.zmark.org"'                                                                                         # Line above prompts dns seeders, this line sets default
sed -i "64s/.*/        vSeeds.push_back(CDNSSeedData(${DNS_SEED_NODES})); \/\/ Edited via script/" chainparams.cpp                                                  # Insert seed nodes into code
#                                                                                                                                                                   # LOAD & CONFIGURE PREFIX MAP
function auto_prefix() { echo ${x[${1}]}; }                                                                                                                         # Declare function used by prefix array
unset x && declare -A x                                                                                                                                             # Ensure variable isnt used and declare array
x['A']=23;x['B']=25;x['C']=28;x['D']=30;x['E']=33;x['F']=35;x['G']=38;x['H']=40;x['J']=43;x['K']=45;x['L']=48;x['M']=50;x['N']=53;x['P']=55;x['Q']=58               # L
x['S']=63;x['T']=65;x['U']=68;x['V']=70;x['W']=73;x['X']=75;x['Y']=78;x['Z']=80;x['a']=83;x['b']=85;x['c']=88;x['d']=90;x['e']=93;x['f']=95;x['g']=98               # O
x['i']=103;x['j']=105;x['k']=108;x['m']=110;x['n']=113;x['o']=115;x['p']=118;x['q']=120;x['r']=123;x['s']=125;x['t']=128;x['u']=130;x['3']=5;x['1']=0               # A
x['x']=138;x['y']=140;x['z']=143;x['2']=3;x['4']=8;x['5']=10;x['6']=15;x['7']=15;x['8']=18;x['9']=20;x['w']=135;x['h']=100;x['R']=60;x['v']=133                    # D -> prefix data into array
echo -e "\nWe are about to configure your forks prefix's, would you like to enter them manually (a number between 0-222)\n"                                         # 
echo "or would you rather directly enter your prefered characters automatically. (an alphanumeric charachter)"                                                      # 
read -p "Enter 1 for auto or 0 for manual. [1]: " PREFIX_INPUT_MODE                                                                                                 # Mode selection
[[ ! ${PREFIX_INPUT_MODE} ]] && PREFIX_INPUT_MODE='1'                                                                                                               # If mode defaulted use auto-mode
if [[ ${PREFIX_INPUT_MODE}='0' ]]; then                                                                                                                             # Check mode (conditional)
echo "You are in manual mode, you must enter the decimal number to be encoded as your prefix." || \                                                                 #
read -p "Enter your PUBLIC key prefix [143]: " PUBLIC_PREFIX                                                                                                        # Prompt for decimal   (conditional true)
else                                                                                                                                                                #
echo "Allowed charachers ---> 123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"                                                                           # Any other character will break the code
read -p "Enter your PUBLIC key prefix character [z]: " PUBLIC_PREFIX                                                                                                # Prompt for character (conditional false)
fi                                                                                                                                                                  #
if [[ ! ${PUBLIC_PREFIX} ]]; then                                                                                                                                   # If pormpt defaulted
[[ ${PREFIX_INPUT_MODE}='1' ]] && PUBLIC_PREFIX='z' || PUBLIC_PREFIX='143'                                                                                          # Set defaults according to mode
fi                                                                                                                                                                  #
[[ ${PREFIX_INPUT_MODE}='1' ]] && PUBLIC_PREFIX=$(auto_prefix ${PUBLIC_PREFIX})                                                                                     # Set public prefix for insertion into code
sed -i "66s/.*/        base58Prefixes[PUBKEY_ADDRESS] = list_of(${PUBLIC_PREFIX}); \/\/ Edited via script/" chainparams.cpp                                         # Insert public prefix into code
PRIVATE_PREFIX=$((${PUBLIC_PREFIX}+128))                                                                                                                            # Private prefix is 128 + PUBLIC_PREFIX
sed -i "68s/.*/        base58Prefixes[SECRET_KEY]     = list_of(${PRIVATE_PREFIX}); \/\/ Edited via script - PUBKEY_PREFIX + 128/" chainparams.cpp                  # Insert private prefix into code
echo -e "\nAUTOMATICALLY CONFIGURING YOUR TESTNET SETTINGS WITH RPCPORT=1${RPC_PORT}, P2PPORT=1${P2P_PORT}...\n"                                                    # Configure testnet
sed -i "117s/.*/        nDefaultPort = 1${P2P_PORT}; \/\/ Edited via script/" chainparams.cpp                                                                       # Insert P2P_PORT
sed -i "118s/.*/        nRPCPort     = 1${RPC_PORT}; \/\/ Edited via script/" chainparams.cpp                                                                       # Insert RPC_PORT
read -p 'Configure diff retarget time (default is 1 day) [86400]: ' DIFF_RETARGET_TIME_IN_SECONDS                                                                   # Prompt retarget (seconds)
[[ ! ${DIFF_RETARGET_TIME_IN_SECONDS} ]] && DIFF_RETARGET_TIME_IN_SECONDS='86400'                                                                                   # If prompt defaulted set defaults
sed -i "1230s/.*/ static const int64_t nTargetTimespan = ${DIFF_RETARGET_TIME_IN_SECONDS}; \/\/ Edited via script - values unit is seconds/" main.cpp               # Insert retarget into code
read -p 'Configure block time (default is 2 mins) [120]: ' BLOCK_TIME_IN_SECONDS                                                                                    # Prompt block time (seconds)
[[ ! ${BLOCK_TIME_IN_SECONDS} ]] && BLOCK_TIME_IN_SECONDS='120'                                                                                                     # If prompt defaulted set defaults
sed -i "1231s/.*/ static const int64_t nTargetSpacing = ${BLOCK_TIME_IN_SECONDS}; \/\/ Edited via script - values unit is seconds/" main.cpp                        # Insert block time into code
echo Done. Good!                                                                                                                                                    # Exit
