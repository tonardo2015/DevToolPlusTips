#!/bin/sh

#tc qdisc add dev eth0 root netem corrupt 30%
#sleep 60
#tc qdisc change dev eth0 root netem duplicate 15%
#sleep 30
#tc qdisc change dev eth0 root netem loss 5%
#sleep 30
#tc -s qdisc show dev eth0
#tc qdisc del dev eth0 root netem
CFG='./test.conf'
source $CFG

control="add"
cmd_base="tc qdisc $control dev eth0 root netem"

cmd_show="tc -s qdisc show dev eth0"
cmd_del="tc qdisc del dev eth0 root netem"

function progress(){
    duration=$1
    pacer="."
    flag=0
    echo "duration: $duration seconds"

    while [ $duration -gt 0 ]; do
	flag=$(($duration % 2))
	if [ $flag -eq 0 ]; then
	    pacer="."
	else
	    pacer="+"
	fi
	#echo -n "."
	echo -n "$pacer"
        duration=$(($duration - 1))
	sleep 1
    done
    echo 
}

function execute(){
    operation=$1
    percent=$2
    timer=$3
    echo "Start packet $operation..."
    cmd="$cmd_base $operation $percent%"
    echo $cmd
    $cmd
    progress $timer
}

function backendJobs(){

cmd="uemcli -u $array_user -p $array_passwd -d 10.229.90.31 /metrics/value/rt -path sp.spa.net.device.spa_mgmt.errorsInRate show -interval 5"
echo $cmd

}


function start(){
    #execute corrupt 30 120
    backendJobs
    control="change"
    #execute duplicate 15 60
    #execute loss 15 30 
    echo $cmd_show
    #$cmd_show
    echo $cmd_del
    #$cmd_del
}

#__main__
start

