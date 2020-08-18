# Example output of swarm: 
#        Name: os-d8532                Mgmt IP: 10.228.45.224            Mgmt IPV6:
#       Model: Oberon Simulator        Backend:                            Version: N1-D32-24G
#       Disks: 32                  Bound Disks:                       Capacity(TB):
#  Lab IP SPA: 10.228.45.225      Terminal SPA:                            PDU SPA:
#  Lab IP SPB: 10.228.45.226      Terminal SPB:                            PDU SPB:
#  BMC IP SPA:                      BMC IP SPB:                         Last crawl: 2019-08-04 02:16:47.08
#       SRM A:                           SRM B:                      Crawled model:
#     I/O IPs: spa0_0:10.228.45.236, spb0_0:10.228.45.237
#    Category: Unity                     Owner: Richard Corley (corler)   Reserved by:
#   Serial # : FCNCH1972C2DE1 (tag)                                   Lab Location:
#   Serial # : FCNCH1972C2DE1 (chassis)                                       Type: Virtual
#         URL: https://hubv1.corp.emc.com/services/equipment_management#systemDetails::storagesystem=FCNCH1972C2DE1
#       State: In service         State reason:
#       Pools: [SPE Unused VMs]
#        Tags:
#       Image: c4dev_HEAD.1564794474
#       Notes:
#
#SOLMUX status:
#  No information for os-d8532 ()
#


array_name=""
array_spa=""
array_spb=""
array_mgmt=""
array_user=""
array_passwd=""
array_default_passwd=""
lic_path=""
initialized=""
ssh_passwd=""

NET_CFG_FILE="./array_network.conf"
ARRAY_CFG_FILE="./test.conf"
source "$NET_CFG_FILE"
source "$ARRAY_CFG_FILE"


function get_array_config() {

array_name=$1
FILE=$array_name.tmp
if [ ! -f "$FILE" ]; then
swarm $1 > $FILE
fi
array_spa=$(cat $FILE | grep "Lab IP SPA" | awk -F':' 'NR=2{split($2,a," ");print a[1]}')
array_spb=$(cat $FILE | grep "Lab IP SPB" | awk -F':' 'NR=2{split($2,a," ");print a[1]}')
array_mgmt=$(cat $FILE | grep "Mgmt IP" | awk -F':' '{print $3}' | cut -d" " -f2)
echo "[$array_name]: array_spa=$array_spa;array_spb=$array_spb;array_mgmt=$array_mgmt"

}


function set_config() {

sudo sed -i "s/^\($1\s*=\s*\).*\$/\1$2/" "$ARRAY_CFG_FILE"

}


function set_mgmt_ip() {

array_name=$1
array_net_key=${array_name/-/_}
array_net=${!array_net_key}
echo "$array_name's network address is $array_net"
mgmt_setup_cmd="svc_initial_config -a -f $array_name -n \"$array_net\""
#mgmt_setup_cmd="ls -la"
echo "$mgmt_setup_cmd"

/usr/bin/expect << EOD
proc sendline {line} { send -- "$line\r" }
set timeout -1
spawn ssh root@$array_spa
expect "yes/no" {
send "yes\r"
    expect "*?assword" { send "$ssh_passwd\r" }
} "*?assword" { send "$ssh_passwd\r" }
expect {[#>$]} { 
	send {pgrep ECOM | wc -l}
	send "\r" }
expect {
    "0" {
	    send "ssh peer\r"
            expect {[#>$]} {
		send {$mgmt_setup_cmd}
		send "\r"} 
	        expect -re "# " {
		    send {echo "ECOM is in SPB"}
		    send "\r"
		    expect -re "# " {send "logout\r"}}
	        expect -re "# " {send "logout\r"}	
	    } 
    "1" {
	    send {$mgmt_setup_cmd} 
       	    send "\r" 
	    expect -re "# " {
		send {echo "ECOM is in SPA"}
		send "\r"
		expect -re "# " {send "logout\r"}
	    }  
	} 
      }

expect eof
EOD

}


function initialize() {

cmd_str="uemcli -d $array_mgmt -sslPolicy accept -u Local/admin -p"
before_reset="$cmd_str $array_default_passwd"
after_reset="$cmd_str $array_passwd"

eula_cmd="$before_reset /sys/eula set -agree yes"
pwd_reset_cmd="$before_reset /user/account -id user_admin set -passwd $array_passwd -force"
lic_cmd="$after_reset -upload -f $lic_path license"

cfg_flag_key="${array_name/-/_}_initialized"
#echo "cfg_flag_key is: ${cfg_flag_key}"
#echo "cfg_flag_key content is ${!cfg_flag_key}"

if [ -z "${!cfg_flag_key}" ]; then
    echo "$eula_cmd"
    $eula_cmd

    echo "$pwd_reset_cmd"
    $pwd_reset_cmd

    echo "$lic_cmd"
    $lic_cmd

    #set_config initialized 1
    echo "${cfg_flag_key}=1" | sudo tee --append "$ARRAY_CFG_FILE"
else
    echo "${array_name} has already been initialized...no action required!"
fi

}


function version_check() {

build_file=$array_name.build
cmd="uemcli -d $array_mgmt -u $array_user -p $array_passwd -noHeader -sslPolicy store /sys/soft/ver show"
echo $cmd
$cmd > $build_file
array_bVer=$(echo $(cat ./$build_file | grep Version | cut -d'=' -f2 | xargs))
echo -e "\"\e[32m$array_name\e[0m\" build version is \"\e[95m$array_bVer\e[0m\""
rm -rf $build_file

}


function health_check() {
# Note: only use one echo in health_check as echo is used as way to return value
# additional echo would mess up the return value.

# nc -w 2 -v $array_mgmt 443 < /dev/null; echo $? 
chk_cmd="nc -w 2 -v $array_mgmt 443 < /dev/null; echo \$?"
$chk_cmd

# $?==0 means mangement interface check succeeds, return code is 0, else return code is 1
if (($?)); then
    _mgmt_ip_up=0
else
    _mgmt_ip_up=1
fi

echo "$_mgmt_ip_up"

}


function progress() {
#  pid="$1"
#  kill -n 0 "${pid}" &> /dev/null && echo -ne "please wait"
#  while kill -n 0 "${pid}" &> /dev/null ; do
  echo "Wait for mgmt interface up..."
  timer=15
  mgmt_ip_up=$( health_check )
  while [ $mgmt_ip_up -eq 0 ]; do
    echo -n "."
    sleep 3 
    mgmt_ip_up=$( health_check )
    timer=$(($timer - 1))
    if [ $timer -eq 0 ]
    then 
	echo "Timeout: mgmt interface($array_mgmt) could not be brought up in $timer seconds!!!"
	break
    fi
  done
}


function do_mgmt_ip_setup() {

mgmt_ip_up=$( health_check )
echo "mgmt_ip_up: ($mgmt_ip_up)"

if (($mgmt_ip_up)) ; then
    echo -e "Array \"\e[32m$array_name\e[0m\" management IP ($array_mgmt) is up"
else
    echo -e "\e[1;31mArray $array_name's management IP ($array_mgmt) is NOT up\e[0m"
    set_mgmt_ip $array_name
    progress # Wait for mgmt IP up
fi

}


#get_array_config $array_name
#echo "Main: $array_spa $array_spb $array_mgmt"

#Configuration "array_list" is defined in test.conf

# Main() 
echo "${array_list[@]}"
for iter in "${array_list[@]}"; do
    get_array_config $iter
    #health_check
    do_mgmt_ip_setup
    initialize
    version_check
done
