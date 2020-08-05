#!/bin/bash

#auto_install_upgrade.sh -a os-d8564 -i /builds/storage/KH/PIE-unity-integration-goshawk-842925-201910190804/output/image/NEXTOS_DEBUG/OS-c4dev_PIE_4737R-5.1.0.1.1.097-NEXTOS_DEBUG.tgz.bin | tee /tmp/os-d8546-inst.log > /dev/null &


_DEBUG="off"
CFG_FILE="./test.conf"
ParentDir="/tmp/"
index=0
install_option=upgrade
pattern='.tgz.bin'

array_name=""
array_spa=""
array_spb=""
array_mgmt=""
array_user=""
array_passwd=""

source "$CFG_FILE" 

function DEBUG()
{
 [ "$_DEBUG" == "on" ] &&  $@
}


function usae() {
    echo "Usage: xxx"
}


function get_array_config() {

  array_name=$1
  FILE=$array_name.tmp
  if [ ! -f "$FILE" ]; then
  swarm "$array_name" > $FILE
  fi
  array_spa=$(cat $FILE | grep "Lab IP SPA" | awk -F':' 'NR=2{split($2,a," ");print a[1]}')
  array_spb=$(cat $FILE | grep "Lab IP SPB" | awk -F':' 'NR=2{split($2,a," ");print a[1]}')
  array_mgmt=$(cat $FILE | grep "Mgmt IP" | awk -F':' '{print $3}' | cut -d" " -f2)
  echo "[$array_name]: array_spa=$array_spa;array_spb=$array_spb;array_mgmt=$array_mgmt"

}


function validateBuild() {

    if [[ $install_option == "upgrade" ]]; then
	pattern='.tgz.bin.gpg'
    else
	pattern='.tgz.bin'
    fi

    validUg=$(echo $build | grep "$pattern" | wc -l)
    echo "Build check result:($validUg)"

    if [ $validUg -eq 0 ]; then
	echo "Package type is not for $install_option ($pattern)! Please check your $install_option bundle configuration. Current bundle definition is ($build)"
        exit
    fi
}


function upgrade() {

    my_array=$1
    get_array_config $my_array
    cmdBase="uemcli -sslPolicy accept -noHeader -u $array_user -p $array_passwd -d $array_mgmt"
    cmdUpload="$cmdBase -upload -f $build upgrade"
    echo "$cmdUpload"
    $cmdUpload | tee -a "$logPath"

    #cmd="$cmdBase /sys/soft/ver -type candidate show -detail | grep ID | cut -d'=' -f2 | xargs echo"
    cmd="$cmdBase /sys/soft/ver -type candidate show -detail"
    #echo $cmd
    cID=`$cmd | grep ID | cut -d'=' -f2 | xargs echo`
    echo "cID: ($cID)"
    cmdCrtUpgrade="$cmdBase /sys/soft/upgrade create -candId $cID" 

    echo "$cmdCrtUpgrade"
    $cmdCrtUpgrade | tee -a "$logPath"
}


function doInstall() {

    my_array=$1
    if [ "$install_option" == "install" ]; then
        cmd_inst="auto_install_upgrade.sh -a $my_array -i $build > $logPath 2>&1 &"
	    #echo $cmd_inst
        #runuser -l c4dev -c "auto_install_upgrade.sh -a $iter -i $build > $logPath 2>&1 &"
        runuser -l c4dev -c "$cmd_inst"
    else
	    upgrade $my_array
    fi
}


# main 
#[ $# -lt 1 ] && usage

echo $build
echo "${array_list[@]}"
validateBuild

for iter in "${array_list[@]}"; do
   postfix="-inst.log"
   logPath="$ParentDir$iter$postfix"
   #&sudo cat /dev/null > "$logPath"
   if [ -f "$logPath" ]; then
       chown c4dev:users "$logPath"
       runuser -l c4dev -c "cat /dev/null > \"$logPath\""
   fi
   LOG_FILES[$index]=$logPath
   #index=$(echo "$index+1" | bc -l)
   index=$(($index + 1))
   DEBUG set -x
   doInstall $iter
   DEBUG set +x
done

echo "${#array_list[@]} array $install_option job(s) have started in the backend, check the *-inst.log in $ParentDir directory for progress!"

for i in "${LOG_FILES[@]}"; do
    echo -e "\e[32m$i\e[0m"
done
