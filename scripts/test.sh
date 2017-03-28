#!/usr/bin/env bash#!/bin/bash
a=$(blkid | awk '{print $1}' | sed 's/.$//')

for i in "${a[@]}"
do
  for x in {a..z}
  do
    if [$i = "/dev/sd$x"]; then
        echo "$x is a match"
    fi
  done
done



#!/bin/bash
#a=$(blkid | awk '{print $1}' | sed 's/.$//')
array=($(fdisk -l | grep "Disk /dev/sd" | awk '{print $2'} | sed 's/.$//'))

for i in "${array[@]}"
do
  for x in {b..z}
  do
    if [ $i="/dev/sd$x" ]; then
       echo "/dev/sd$x"
    else
       excho "/dev/sd$x" does not exist
    fi
  done
done