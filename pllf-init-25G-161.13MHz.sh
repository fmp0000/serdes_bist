#!/bin/sh
# SPDX-License-Identifier: BSD-3-Clause
# Copyright 2024 NXP
####################################################################
#set -x

# Implement following procedure from 28G_Lynx_Compliance_Test_v2.6.pdf
# 5.13.1.1.2 12.890625 GHz Clock Net, 25.78125 GHz VCO3F, 161.1328 MHz Ref, LBW PLLF Setup

#Using SERDES1 Protocol: 13 (0xd)
#SERDES1 Reference : Clock1 = 161.13MHz Clock2 = 161.13MHz
#25GE, 50GE, 100GE (each lane: 25.78125 Gbaud)  0 161.1328125 MHz
#25/50/100G Ethernet: 10110 (PLLF) 
# 10110b - 12.890625G clock net on 25.78125G VCO, PLLS or PLLF


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
Write $PLLFCR0 0x00040000 # 0000 0000 0000 0100 0000 0000 0000 0000 Program on PLLF according to Table 8-1-14:
echo -n .3  
Read  $PLLFCR0 0x00040000 0x301f0000 # xxLL xxxx xxxL LHLL xxxx xxxx xxxx xxxx Confirm on PLLF according to Table 8-1-14:
echo -n .4  
Write $PLLFCR1 0x96100008 # 1001 0110 0001 0000 0000 0000 0000 1000 Program on PLLF:
echo -n .5  
Read  $PLLFCR1 0x96100008 0x9f3bb73b # HxxH LHHL xxLH LxLL LxLL xLLL xxLL HxLL Confirm on PLLF:
echo -n .6  
Write $PLLFCR2 0x00000000 # 0000 0000 0000 0000 0000 0000 0000 0000 Program on PLLF:
echo -n .7  
Read  $PLLFCR2 0x00000000 0xeb8f887f # LLLx LxLL Lxxx LLLL Lxxx Lxxx xLLL LLLL Confirm on PLLF:
echo -n .8  
Write $PLLFCR3 0x00003000 # 0000 0000 0000 0000 0011 0000 0000 0000 Program on PLLF:
echo -n .9  
Read  $PLLFCR3 0x00003000 0x33fff770 # xxLL xxLL LLLL LLLL LLHH xLLL xLLL xxxx Confirm on PLLF:
echo -n .10 
Write $PLLFCR4 0x00005000 # 0000 0000 0000 0000 0101 0000 0000 0000 Program on PLLF:
echo -n .11 
Read  $PLLFCR4 0x00005000 0xe3fffbff # LLLx xxLL LLLL LLLL LHLH LxLL LLLL LLLL Confirm on PLLF:
echo -n .12 
Write $PLLFCR5 0x00000000 # 0000 0000 0000 0000 0000 0000 0000 0000 Program on PLLF:
echo -n .13 
Read  $PLLFCR5 0x00000000 0xf007000f # LLLL xxxx xxxx xLLL xxxx xxxx xxxx LLLL Confirm on PLLF:
echo -n .14 
Write $PLLFCR6 0x00000000 # 0000 0000 0000 0000 0000 0000 0000 0000 Program on PLLF:
echo -n .15 
Readw  $PLLFCR6 0x00000000 0x3333ffff # xxLL xxLL xxLL xxLL LLLL LLLL LLLL LLLL Confirm on PLLF:
echo -n .16 
Write $PLLFCR8 0x00000000 # 0000 0000 0000 0000 0000 0000 0000 0000 Program on PLLF:
echo -n .17 
Read  $PLLFCR8 0x00000000 0xc3370000 # LLxx xxLL xxLL xLLL xxxx xxxx xxxx xxxx Confirm on PLLF:
echo -n .18 
Write $PLLFCR9 0x00000000 # 0000 0000 0000 0000 0000 0000 0000 0000 Program on PLLF:
echo -n .19 
Read  $PLLFCR9 0x00000000 0xe7300000 # LLLx xLLL xxLL xxxx xxxx xxxx xxxx xxxx Confirm on PLLF:


echo
echo SUCCESS

