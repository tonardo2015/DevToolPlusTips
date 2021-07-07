#!/bin/bash
printf y | yum install gdisk

# There would be 3 Volume Group (VGs) for performance test environment: VolGroup00, vg01 and ssd_vg
# VolGroup00: system VG for /, /var, /home etc, 3 drives, sda/sdb/sdc, 21TiB
# vg01: VG for database storage, 15 drives, sdd-sdr, 105TiB
# ssd_vg: VG for SSD, 2 SSD drives, sdw/sdx, 512GiB * 2

crt_vg()
{
  vg_name="$1"
  drives="$2"
  cmd="vgcreate $vg_name $drives"
  echo $cmd
  $cmd
}

crt_lv()
{
  vg_name=$1
  lv_name=$2
  size=$3
  mount_ptr=$4

  cmd="lvcreate -n $lv_name --size $size $vg_name"
  echo $cmd
  $cmd
  cmd="mkfs.xfs /dev/$vg_name/$lv_name"
  echo $cmd
  $cmd
  mkdir $mount_ptr
  drive_id=`blkid | grep $lv_name | cut -d'=' -f2 | cut -d' ' -f1 | xargs echo`
  echo $drive_id
  cfg_data_drive="UUID=$drive_id $mount_ptr xfs defaults 0 2"
  if [ -n "$drive_id" ]; then
    echo "$cfg_data_drive" >> /etc/fstab
  fi
}

format_drives()
{
  drive_id_list=$(echo {b..r})
  for d_id in $drive_id_list; do
    dev="/dev/sd${d_id}"
    printf "n\n\n\n\n\nw\ny\n" | gdisk /dev/sd$d_id
  done

  # extend system VG
  vg_name=`vgs | awk 'NR==2 {print $1}'`
  echo $vg_name
  sys_drive_list="/dev/sdb1 /dev/sdc1"
  vgextend $vg_name ${sys_drive_list}

  # /var directory corresponding device
  var_dev=`df -h -x squashfs -x tmpfs -x devtmpfs | grep /var | awk '{print $1}'`
  echo $var_dev

  lvextend -L+10T $var_dev
  fsadm resize $var_dev

  # /data directory
  data_drives=""
  data_drive_id_list=$(echo {d..r})
  for d_id in $data_drive_id_list; do
    dev="/dev/sd${d_id}"
    data_drives="${data_drives} ${dev}1"
  done

  vg_data="vg01"
  lv_name="lv_data"
  mount_ptr_data="/data"

  crt_vg "$vg_data" "$data_drives"
  crt_lv "$vg_data" "$lv_name" "105T" "$mount_ptr_data"

  mount -a
}

format_ssd_drives()
{
  vg_ssd="vg05"
  ssd_lv_name="lv_ssd_data"
  #ssd_drives="/dev/sdw1 /dev/sdx1"
  ssd_drives=""
  mount_ptr_ssd="/ssd_data"

  drive_id_list=$(echo {w..x})
  for d_id in $drive_id_list; do
    dev="/dev/sd${d_id}"
    ssd_drives="${ssd_drives} ${dev}1"
    printf "n\n\n\n\n\nw\ny\n" | gdisk $dev
  done

  crt_vg "$vg_ssd" "$ssd_drives"
  crt_lv "$vg_ssd" "$ssd_lv_name" "850G" "$mount_ptr_ssd"

  mount -a
}

get_size()
{
    mount_ptr=$1
    vol=`df -H | grep $mount_ptr | awk '{print $1}'`
    size_all=`df -H | grep $mount_ptr | awk '{print $2}'`
    size_unit=`df -H | grep $mount_ptr | awk '{print $2}' | xargs echo -n | tail -c 1`
    size=`echo "${size_all::-1}"`
    #echo "size=$size"
    #echo "size_unit=$size_unit"
    #echo "vol=$vol"
    eval "size=$size_all"
    eval "size_unit=$size_unit"
    eval "vol=$vol"
}

extend()
{
    target_size_all=$1
    vol=$2
    unit=`echo $1 | awk '{print substr($0,length,1)}'`
    echo $unit
    if [ "G"=="$unit" ]; then
        echo "Unit is $unit"
    elif [ "T"=="$unit" ]; then
        echo "Unit is $unit"
    else
        echo "Invalid unit: $unit"
    fi

    #len=`echo ${#str}-2 | bc`
    #echo "${str:0:$len}"

    len=`echo ${#target_size_all}-1 | bc`
    target_size=`echo "${target_size_all:0:$len}"`
    echo "target size is: $target_size"
    echo "current size is: $size"
    current_size=`echo ${size:0:$((${#size}-1))}`
    delta_size=$(($target_size-$current_size))
    cmd="lvextend -L+${delta_size}${unit} ${vol}"
    echo "$delta_size"
    echo $cmd
}

#get_size $mount_ptr
#echo ${size}
#echo ${size_unit}
#echo ${vol}

#target_size_all=100G
#extend $target_size_all ${vol}
format_drives
#format_ssd_drives
