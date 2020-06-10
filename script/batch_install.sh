#!/bin/sh

#auto_install_upgrade.sh -a os-d8564 -i /builds/storage/KH/PIE-unity-integration-goshawk-842925-201910190804/output/image/NEXTOS_DEBUG/OS-c4dev_PIE_4737R-5.1.0.1.1.097-NEXTOS_DEBUG.tgz.bin | tee /tmp/os-d8546-inst.log > /dev/null &

CFG_FILE="./test.conf"
source "$CFG_FILE" 

echo $build
echo ${array_list[@]}

for iter in "${array_list[@]}"; do
   postfix="-inst.log"
   logPath="/tmp/$iter$postfix"
   cmd_inst="auto_install_upgrade.sh -a $iter -i $build > $logPath 2>&1 &"
   #echo "$cmd_inst"
   runuser -l c4dev -c "auto_install_upgrade.sh -a $iter -i $build > $logPath 2>&1 &"
done

echo "${#array_list[@]} array re-init job(s) have started in the backend, check the *-inst.log in /tmp directory for progress!"
