#!/bin/sh
# SPDX-License-Identifier: BSD-3-Clause
# Copyright 2024 NXP
####################################################################
#set -x

# Implement following procedure from 28G_Lynx_Compliance_Test_v2.6.pdf
# 4.4.2.1 PLLF Initialization/Recalibration Procedure

# prerequisite git clone https://github.com/pengutronix/memtool.git

print_usage()
{
echo "usage: ./init.sh <serdes 0-2> <lane 0-7> "
}

# check parameters
if [ $# -lt 2 ];then
        echo Arguments wrong.
        print_usage
        exit 1
fi

SERDES=$1
LANE=$2
CCSR_SERDES_OFF=$((0x1EA0000 + $SERDES*0x10000))
RSTCTL=$(($CCSR_SERDES_OFF + 0x000))
GR0=$(($CCSR_SERDES_OFF + 0x004))
TCR0=$(($CCSR_SERDES_OFF + 0x008))
LCAPCR0=$(($CCSR_SERDES_OFF + 0x020))
LCAPCR1=$(($CCSR_SERDES_OFF + 0x024))
LCAPCR2=$(($CCSR_SERDES_OFF + 0x028))
LCAPCR3=$(($CCSR_SERDES_OFF + 0x02C))
RCAPCR0=$(($CCSR_SERDES_OFF + 0x040))
RCAPCR1=$(($CCSR_SERDES_OFF + 0x044))
RCAPCR2=$(($CCSR_SERDES_OFF + 0x048))
RCAPCR3=$(($CCSR_SERDES_OFF + 0x04C))

PLLFRSTCTL=$(($CCSR_SERDES_OFF + 0x400)) 
PLLFCR0=$(($CCSR_SERDES_OFF + 0x404)) 
PLLFCR1=$(($CCSR_SERDES_OFF + 0x408)) 
PLLFCR2=$(($CCSR_SERDES_OFF + 0x40C)) 
PLLFCR3=$(($CCSR_SERDES_OFF + 0x410)) 
PLLFCR4=$(($CCSR_SERDES_OFF + 0x414)) 
PLLFCR5=$(($CCSR_SERDES_OFF + 0x418)) 
PLLFCR6=$(($CCSR_SERDES_OFF + 0x41C)) 
PLLFCR7=$(($CCSR_SERDES_OFF + 0x420)) 
PLLFCR8=$(($CCSR_SERDES_OFF + 0x424)) 
PLLFCR9=$(($CCSR_SERDES_OFF + 0x428)) 
PLLFSSCR0=$(($CCSR_SERDES_OFF + 0x430)) 
PLLFSSCR1=$(($CCSR_SERDES_OFF + 0x434)) 
PLLFSSCR2=$(($CCSR_SERDES_OFF + 0x438)) 
PLLFSSCR3=$(($CCSR_SERDES_OFF + 0x43C)) 
PLLFCB0=$(($CCSR_SERDES_OFF + 0x4F0)) 
PLLFCB1=$(($CCSR_SERDES_OFF + 0x4F4)) 

PLLSRSTCTL=$(($CCSR_SERDES_OFF + 0x500)) 
PLLSCR0=$(($CCSR_SERDES_OFF + 0x504)) 
PLLSCR1=$(($CCSR_SERDES_OFF + 0x508)) 
PLLSCR2=$(($CCSR_SERDES_OFF + 0x50C)) 
PLLSCR3=$(($CCSR_SERDES_OFF + 0x510)) 
PLLSCR4=$(($CCSR_SERDES_OFF + 0x514)) 
PLLSCR5=$(($CCSR_SERDES_OFF + 0x518)) 
PLLSCR6=$(($CCSR_SERDES_OFF + 0x51C)) 
PLLSCR7=$(($CCSR_SERDES_OFF + 0x520)) 
PLLSCR8=$(($CCSR_SERDES_OFF + 0x524)) 
PLLSCR9=$(($CCSR_SERDES_OFF + 0x528)) 
PLLSSSCR0=$(($CCSR_SERDES_OFF + 0x530)) 
PLLSSSCR1=$(($CCSR_SERDES_OFF + 0x534)) 
PLLSSSCR2=$(($CCSR_SERDES_OFF + 0x538)) 
PLLSSSCR3=$(($CCSR_SERDES_OFF + 0x53C)) 
PLLSCB0=$(($CCSR_SERDES_OFF + 0x5F0)) 
PLLSCB1=$(($CCSR_SERDES_OFF + 0x5F4)) 

GCR0=$(($CCSR_SERDES_OFF + 0x800+ $LANE*0x100))
TRSTCTL=$(($CCSR_SERDES_OFF + 0x820+ $LANE*0x100))
TGCR0=$(($CCSR_SERDES_OFF + 0x824+ $LANE*0x100))
TGCR1=$(($CCSR_SERDES_OFF + 0x828+ $LANE*0x100))
TGCR2=$(($CCSR_SERDES_OFF + 0x82C+ $LANE*0x100))
TECR0=$(($CCSR_SERDES_OFF + 0x830+ $LANE*0x100))
TECR1=$(($CCSR_SERDES_OFF + 0x834+ $LANE*0x100))
RRSTCTL=$(($CCSR_SERDES_OFF + 0x840+ $LANE*0x100))
RGCR0=$(($CCSR_SERDES_OFF + 0x844+ $LANE*0x100))
RGCR1=$(($CCSR_SERDES_OFF + 0x848+ $LANE*0x100))
RECR0=$(($CCSR_SERDES_OFF + 0x850+ $LANE*0x100))
RECR1=$(($CCSR_SERDES_OFF + 0x854+ $LANE*0x100))
RECR2=$(($CCSR_SERDES_OFF + 0x858+ $LANE*0x100))
RECR3=$(($CCSR_SERDES_OFF + 0x85C+ $LANE*0x100))
RECR4=$(($CCSR_SERDES_OFF + 0x860+ $LANE*0x100))
RCCR0=$(($CCSR_SERDES_OFF + 0x868+ $LANE*0x100))
RCCR1=$(($CCSR_SERDES_OFF + 0x86C+ $LANE*0x100))
RCPCR0=$(($CCSR_SERDES_OFF + 0x870+ $LANE*0x100))
RSCCR0=$(($CCSR_SERDES_OFF + 0x874+ $LANE*0x100))
RSCCR1=$(($CCSR_SERDES_OFF + 0x878+ $LANE*0x100))
TTLCR0=$(($CCSR_SERDES_OFF + 0x880+ $LANE*0x100))
TTLCR1=$(($CCSR_SERDES_OFF + 0x884+ $LANE*0x100))
TTLCR2=$(($CCSR_SERDES_OFF + 0x888+ $LANE*0x100))
TTLCR3=$(($CCSR_SERDES_OFF + 0x88C+ $LANE*0x100))
TCSR0=$(($CCSR_SERDES_OFF + 0x8A0+ $LANE*0x100))
TCSR1=$(($CCSR_SERDES_OFF + 0x8A4+ $LANE*0x100))
TCSR2=$(($CCSR_SERDES_OFF + 0x8A8+ $LANE*0x100))
TCSR3=$(($CCSR_SERDES_OFF + 0x8AC+ $LANE*0x100))
TCSR4=$(($CCSR_SERDES_OFF + 0x8B0+ $LANE*0x100))
RXCB0=$(($CCSR_SERDES_OFF + 0x8C0+ $LANE*0x100))
RXCB1=$(($CCSR_SERDES_OFF + 0x8C4+ $LANE*0x100))
RXSS0=$(($CCSR_SERDES_OFF + 0x8D0+ $LANE*0x100))
RXSS1=$(($CCSR_SERDES_OFF + 0x8D4+ $LANE*0x100))
RXSS2=$(($CCSR_SERDES_OFF + 0x8D8+ $LANE*0x100))
TXCB0=$(($CCSR_SERDES_OFF + 0x8E0+ $LANE*0x100))
TXCB1=$(($CCSR_SERDES_OFF + 0x8E4+ $LANE*0x100))
TXSS0=$(($CCSR_SERDES_OFF + 0x8F0+ $LANE*0x100))
TXSS1=$(($CCSR_SERDES_OFF + 0x8F4+ $LANE*0x100))
TXSS2=$(($CCSR_SERDES_OFF + 0x8F8+ $LANE*0x100))
	

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

Readw(){
        addr=`printf "0x%08x" $1`
        val=`printf "0x%08x" $2`
        mask=`printf "0x%08x" $3`
        m=0x`memtool md $addr+4|cut -f 2 -d " "`
        m1=$((m&$mask))
        if [ $m1 -ne $(($val)) ];then
                        mx=`printf "0x%08x" $m`
                        echo
                        echo Warning: $mx "&" $mask differ from  $val
        fi
}

Write(){
        addr=`printf "0x%08x" $1`
        val=`printf "0x%08x" $2`
        `memtool mw $addr $val`
}


echo -n .2  
Write $PLLFRSTCTL 0x10000000 # 0001 0000 0000 0000 0000 0000 0000 0000 Program on PLLF: According to Table 8-1-13
echo -n .3  
Read  $PLLFRSTCTL 0x10000000 0x10000030 # xxxH xxxx xxxx xxxx xxxx xxxx xxLL xxxx Confirm on PLLF: According to Table 8-1-13
echo -n .4  
Write $PLLFRSTCTL 0x50000000 # 0101 0000 0000 0000 0000 0000 0000 0000 Program on PLLF: According to Table 8-1-13
echo -n .5  
Read  $PLLFRSTCTL 0x50000000 0x50000030 # xHxH xxxx xxxx xxxx xxxx xxxx xxLL xxxx Confirm on PLLF: According to Table 8-1-13
echo -n .6  
Write $PLLFRSTCTL 0x50000000 # 0101 0000 0000 0000 0000 0000 0000 0000 Program on PLLF: According to Table 8-1-13
echo -n .7  
Read  $PLLFRSTCTL 0x00000000 0x00000030 # xxxx xxxx xxxx xxxx xxxx xxxx xxLL xxxx Confirm on PLLF: According to Table 8-1-13
echo -n .8  
sleep 0.1 # Wait for Logic to settle
echo -n .9  
Write $PLLFRSTCTL 0x50000010 # 0101 0000 0000 0000 0000 0000 0001 0000 Program on PLLF: According to Table 8-1-13
echo -n .10 
Read  $PLLFRSTCTL 0x00000010 0x00000030 # xxxx xxxx xxxx xxxx xxxx xxxx xxLH xxxx Confirm on PLLF: According to Table 8-1-13
echo -n .11 
sleep 0.1 # Wait 2500 us for Analog to power up and PLL calibration to complete from pll_en
echo -n .12 
Write $PLLFRSTCTL 0x50000030 # 0101 0000 0000 0000 0000 0000 0011 0000 Program on PLLF: According to Table 8-1-13
echo -n .13 
Read  $PLLFRSTCTL 0x00000030 0x00000030 # xxxx xxxx xxxx xxxx xxxx xxxx xxHH xxxx Confirm on PLLF: According to Table 8-1-13
echo -n .14 
sleep 0.1 # Wait 400 us for PLL to lock
echo -n .15 
Read  $PLLFRSTCTL 0x00800000 0x00800000 # xxxx xxxx Hxxx xxxx xxxx xxxx xxxx xxxx Confirm: According to Table 8-1-13


echo
echo SUCCESS

