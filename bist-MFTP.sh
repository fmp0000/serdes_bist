#!/bin/sh
# SPDX-License-Identifier: BSD-3-Clause
# Copyright 2024 NXP
####################################################################
#set -x

# Implement following procedure from 28G_Lynx_Compliance_Test_v2.6.pdf
# 8.1.4.1 SerDes Receiver Digital Loopback BIST Procedure using MFTP including Initialization
# 8.1.4.2 SerDes Receiver External Loopback BIST Procedure using MFTP including Initialization

# prerequisite git clone https://github.com/pengutronix/memtool.git

print_usage()
{
echo "usage: ./bist.sh <serdes 0-2> <lane 0-7> <digital loopback 0/1>"
}

# check parameters
if [ $# -lt 3 ];then
        echo Arguments wrong.
        print_usage
        exit 1
fi

SERDES=$1
LANE=$2
LOOPBACK=$3
CCSR_SERDES_OFF=$((0x1EA0000 + $SERDES*0x10000))
TCR0=$(($CCSR_SERDES_OFF + 0x008))
GCR0=$(($CCSR_SERDES_OFF + 0x800+ $LANE*0x100))
TRSTCTL=$(($CCSR_SERDES_OFF + 0x820 + $LANE*0x100))
RRSTCTL=$(($CCSR_SERDES_OFF + 0x840 + $LANE*0x100))
RGCR1=$(($CCSR_SERDES_OFF + 0x848 + $LANE*0x100))
RECR3=$(($CCSR_SERDES_OFF + 0x85c + $LANE*0x100))
RECR4=$(($CCSR_SERDES_OFF + 0x860 + $LANE*0x100))
TCSR0=$(($CCSR_SERDES_OFF + 0x8a0 + $LANE*0x100))
TCSR1=$(($CCSR_SERDES_OFF + 0x8a4 + $LANE*0x100))
TCSR2=$(($CCSR_SERDES_OFF + 0x8a8 + $LANE*0x100))
TCSR3=$(($CCSR_SERDES_OFF + 0x8ac + $LANE*0x100))
TCSR4=$(($CCSR_SERDES_OFF + 0x8b0 + $LANE*0x100))

Read(){
        addr=`printf "0x%08x" $1`
        val=`printf "0x%08x" $2`
        mask=`printf "0x%08x" $3`
        m=0x`memtool md $addr+4|cut -f 2 -d " "`
        m1=$((m&$mask))
        if [ $m1 -ne $(($val)) ];then
                        mx=`printf "0x%08x" $m`
                        echo
                        echo $mx "&" $mask differ from  $val
                        exit
        fi
}

Write(){
        addr=`printf "0x%08x" $1`
        val=`printf "0x%08x" $2`
        `memtool mw $addr $val`
}

Write $TCR0  0x80000000
Write $GCR0  0x00000000

echo "Table 8-8 SerDes Receiver External Loopback BIST using MFTP and Initialization"
echo -n .2
Write $TRSTCTL 0x00000100 # 0000 0000 0000 0000 0000 0001 0000 0000
echo -n .3
Read $TRSTCTL  0x00000100 0x00000130 # xxxx xxxx xxxx xxxx xxxx xxxH xxLL xxxx
echo -n .4
Write $RRSTCTL 0x00000000 # 0000 0000 0000 0000 0000 0000 0000 0000
echo -n .5
Read $RRSTCTL  0x00000000 0x00000030 # xxxx xxxx xxxx xxxx xxxx xxxx xxLL xxxx
if [ $3 -eq 1 ];then
        echo -n .6
        Write $TCSR0   0x90000000 # 1001 0000 0000 0000 0000 0000 0000 0000
        echo -n .7
        Read $TCSR0    0x90000000 0xb0000000 # HxLH xxxx xxxx xxxx xxxx xxxx xxxx xxxx
else
        echo -n .6
        Write $TCSR0   0x80000000 # 1000 0000 0000 0000 0000 0000 0000 0000
        echo -n .7
        Read $TCSR0    0x80000000 0xb0000000 # HxLL xxxx xxxx xxxx xxxx xxxx xxxx xxxx
fi
echo -n .8
Write $TCSR1   0x05000000 # 0000 0101 0000 0000 0000 0000 0000 0000
echo -n .9
Read $TCSR1    0x05000000 0x0f000000 # xxxx LHLH xxxx xxxx xxxx xxxx xxxx xxxx
echo -n .10
Write $TCSR3   0x0040000f # 0000 0000 0100 0000 0000 0000 0000 1111
echo -n .11
Read $TCSR3    0x0040000f 0x03f0000f # xxxx xxLL LHLL xxxx xxxx xxxx xxxx HHHH
echo -n .13
Write $TRSTCTL 0x00000110 # 0000 0000 0000 0000 0000 0001 0001 0000
echo -n .14
Read $TRSTCTL  0x00000110 0x00000130 # xxxx xxxx xxxx xxxx xxxx xxxH xxLH xxxx
echo -n .15
Write $RRSTCTL 0x00000010 # 0000 0000 0000 0000 0000 0000 0001 0000
echo -n .16
Read $RRSTCTL  0x00000010 0x00000030 # xxxx xxxx xxxx xxxx xxxx xxxx xxLH xxxx
echo -n .18
Write $TCSR3   0x0048000f # 0000 0000 0100 1000 0000 0000 0000 1111
echo -n .19
Read $TCSR3    0x0048000f 0x03f8000f # xxxx xxLL LHLL Hxxx xxxx xxxx xxxx HHHH
echo -n .20
Write $TRSTCTL 0x00000130 # 0000 0000 0000 0000 0000 0001 0011 0000
echo -n .21
Read $TRSTCTL  0x00000130 0x00000130 # xxxx xxxx xxxx xxxx xxxx xxxH xxHH xxxx
echo -n .22
Write $TRSTCTL 0x00000030 # 0000 0000 0000 0000 0000 0000 0011 0000
echo -n .23
Read $TRSTCTL  0x00000000 0x00000100 # xxxx xxxx xxxx xxxx xxxx xxxL xxxx xxxx
echo -n .25
Write $RRSTCTL 0x00000030 # 0000 0000 0000 0000 0000 0000 0011 0000
echo -n .26
Read $RRSTCTL  0x00000030 0x00000030 # xxxx xxxx xxxx xxxx xxxx xxxx xxHH xxxx
echo -n .28
Write $RRSTCTL 0x00000030 # 0000 0000 0000 0000 0000 0000 0011 0000
echo -n .29
Read $RRSTCTL  0x00001030 0x00001030 # xxxx xxxx xxxx xxxx xxxH xxxx xxHH xxxx
echo -n .30
Write $TCSR3   0x0248000f # 0000 0010 0100 1000 0000 0000 0000 1111
echo -n .31
Read $TCSR3    0x02000000 0x02000000 # xxxx xxHx xxxx xxxx xxxx xxxx xxxx xxxx
echo -n .32
Write $TCSR3   0x0248000f # 0000 0010 0100 1000 0000 0000 0000 1111
echo -n .33
Read $TCSR3    0x00000000 0x0001ff00 # xxxx xxxx xxxx xxxL LLLL LLLL xxxx xxxx
echo -n .34
Write $TCSR3   0x024c000f # 0000 0010 0100 1100 0000 0000 0000 1111
echo -n .35
Read $TCSR3    0x00040000 0x00040000 # xxxx xxxx xxxx xHxx xxxx xxxx xxxx xxxx
echo -n .37
Write $TCSR3   0x024c000f # 0000 0010 0100 1100 0000 0000 0000 1111
echo -n .38
Read $TCSR3    0x00020000 0x0003ff00 # xxxx xxxx xxxx xxHL LLLL LLLL xxxx xxxx
echo -n .40
Write $TCSR3   0x024c000f # 0000 0010 0100 1100 0000 0000 0000 1111
echo -n .41
Read $TCSR3    0x00000000 0x0000ff00 # xxxx xxxx xxxx xxxx LLLL LLLL xxxx xxxx

echo
echo SUCCESS

