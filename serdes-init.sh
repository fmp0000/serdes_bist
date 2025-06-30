#!/bin/sh
# SPDX-License-Identifier: BSD-3-Clause
# Copyright 2024 NXP
####################################################################
#set -x

# Implement following procedure from 28G_Lynx_Compliance_Test_v2.6.pdf
# 4.3.1 Block Initialization/Reset

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
Write $TCR0 0x00000000 # 0000 0000 0000 0000 0000 0000 0000 0000 Program for Lynx Test mode as in Table 8-1-3:
echo -n .3   
Read  $TCR0 0x00000000 0x80000000 # Lxxx xxxx xxxx xxxx xxxx xxxx xxxx xxxx Confirm Lynx Test mode as in Table 8-1-3:
echo -n .4   
Write $TCR0 0x80000000 # 1000 0000 0000 0000 0000 0000 0000 0000 Program for Lynx Test mode as in Table 8-1-3:
echo -n .5   
Read  $TCR0 0x80000000 0x80000000 #Hxxx xxxx xxxx xxxx xxxx xxxx xxxx xxxx Confirm Lynx Test mode as in Table 8-1-3:
echo -n .6   
Write $RSTCTL 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program on block: According to Table 8-1-1
echo -n .7   
Read  $RSTCTL 0x00000000 0x00000010 #xxxx xxxx xxxx xxxx xxxx xxxx xxxL xxxx Confirm on block: According to Table 8-1-1
echo -n .8   
Write $PLLFRSTCTL 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program on PLLF: Initialize Register as in Table 8-1-13
echo -n .9   
Read  $PLLFRSTCTL 0x00000000 0x00000030 #xxxx xxxx xxxx xxxx xxxx xxxx xxLL xxxx Confirm on PLLF: Initialize Register as in Table 8-1-13
echo -n .10  
Write $PLLSRSTCTL 0x00000000 # 0000 0000 0000 0000 0000 0000 0000 0000 Program on PLLS: Initialize Register as in Table 8-1-13
echo -n .11  
Read  $PLLSRSTCTL 0x00000000 0x00000030 #xxxx xxxx xxxx xxxx xxxx xxxx xxLL xxxx Confirm on PLLS: Initialize Register as in Table 8-1-13
echo -n .12  
Write $TRSTCTL 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program on all lanes: Initialize Register as in Table 8-1-25
echo -n .13  
Read  $TRSTCTL 0x00000000 0x00000130 #xxxx xxxx xxxx xxxx xxxx xxxL xxLL xxxx Confirm on all lanes: Initialize Register as in Table 8-1-25
echo -n .14  
Write $RRSTCTL 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program on all lanes: Initialize Register as in Table 8-1-31
echo -n .15  
Read  $RRSTCTL 0x00000000 0x00000030 #xxxx xxxx xxxx xxxx xxxx xxxx xxLL xxxx Confirm on all lanes: Initialize Register as in Table 8-1-31
echo -n .16  
Write $LCAPCR0 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program: According to Table 8-1-4
echo -n .17  
Read  $LCAPCR0 0x00000000 0x00000110 #xxxx xxxx xxxx xxxx xxxx xxxL xxLx xxxx Confirm: According to Table 8-1-4
echo -n .18  
Write $LCAPCR1 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program: According to Table 8-1-5
echo -n .19  
Read  $LCAPCR1 0x00000000 0x80008000 #Lxxx xxxx xxxx xxxx Lxxx xxxx xxxx xxxx Confirm: According to Table 8-1-5
echo -n .20  
Write $LCAPCR2 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program: According to Table 8-1-6
echo -n .21  
Read  $LCAPCR2 0x00000000 0x70088000 #xLLL xxxx xxxx Lxxx Lxxx xxxx xxxx xxxx Confirm: According to Table 8-1-6
echo -n .22  
Write $RCAPCR0 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program: According to Table 8-1-8
echo -n .23  
Read  $RCAPCR0 0x00000000 0x00000120 #xxxx xxxx xxxx xxxx xxxx xxxL xxLx xxxx Confirm: According to Table 8-1-8
echo -n .24  
Write $RCAPCR1 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program: According to Table 8-1-9
echo -n .25  
Read  $RCAPCR1 0x00000000 0x80008000 #Lxxx xxxx xxxx xxxx Lxxx xxxx xxxx xxxx Confirm: According to Table 8-1-9
echo -n .26  
Write $RCAPCR2 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program: According to Table 8-1-10
echo -n .27  
Read  $RCAPCR2 0x00000000  0x70088000 #xLLL xxxx xxxx Lxxx Lxxx xxxx xxxx xxxx Confirm: According to Table 8-1-10
echo -n .28  
Write $PLLFCR0 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program on PLLF: Initialize Register as in Table 8-1-14
echo -n .29  
Read  $PLLFCR0 0x00000000 0x301f0003 #xxLL xxxx xxxL LLLL xxxx xxxx xxxx xxLL Confirm on PLLF: Initialize Register as in Table 8-1-14
echo -n .30  
Write $PLLSCR0 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program on PLLS: Initialize Register as in Table 8-1-14
echo -n .31  
Read  $PLLSCR0 0x00000000 0x301f0003 #xxLL xxxx xxxL LLLL xxxx xxxx xxxx xxLL Confirm on PLLS: Initialize Register as in Table 8-1-14
echo -n .32  
Write $PLLFCR1 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program on PLLF: Initialize Register as in Table 8-1-15
echo -n .33  
Read  $PLLFCR1 0x00000000 0x9f7bb73b #LxxL LLLL xLLL LxLL LxLL xLLL xxLL LxLL Confirm on PLLF: Initialize Register as in Table 8-1-15
echo -n .34  
Write $PLLSCR1 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program on PLLS: Initialize Register as in Table 8-1-15
echo -n .35  
Read  $PLLSCR1 0x00000000 0x9f7bb73b #LxxL LLLL xLLL LxLL LxLL xLLL xxLL LxLL Confirm on PLLS: Initialize Register as in Table 8-1-15
echo -n .36  
Write $PLLFCR2 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program on PLLF: Initialize Register as in Table 8-1-16
echo -n .37  
Read  $PLLFCR2 0x00000000 0xeb8f887f #LLLx LxLL Lxxx LLLL Lxxx Lxxx xLLL LLLL Confirm on PLLF: Initialize Register as in Table 8-1-16
echo -n .38  
Write $PLLSCR2 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program on PLLS: Initialize Register as in Table 8-1-16
echo -n .39  
Read  $PLLSCR2 0x00000000 0xeb8f887f #LLLx LxLL Lxxx LLLL Lxxx Lxxx xLLL LLLL Confirm on PLLS: Initialize Register as in Table 8-1-16
echo -n .40  
Write $PLLFCR3 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program on PLLF: Initialize Register as in Table 8-1-17
echo -n .41  
Read  $PLLFCR3 0x00000000 0x33fff770 #xxLL xxLL LLLL LLLL LLLL xLLL xLLL xxxx Confirm on PLLF: Initialize Register as in Table 8-1-17
echo -n .42  
Write $PLLSCR3 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program on PLLS: Initialize Register as in Table 8-1-17
echo -n .43  
Read  $PLLSCR3 0x00000000 0x33fff770 #xxLL xxLL LLLL LLLL LLLL xLLL xLLL xxxx Confirm on PLLS: Initialize Register as in Table 8-1-17
echo -n .44  
Write $PLLFCR4 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program on PLLF: Initialize Register as in Table 8-1-18
echo -n .45  
Read  $PLLFCR4 0x00000000 0xe3fffbff #LLLx xxLL LLLL LLLL LLLL LxLL LLLL LLLL Confirm on PLLF: Initialize Register as in Table 8-1-18
echo -n .46  
Write $PLLSCR4 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program on PLLS: Initialize Register as in Table 8-1-18
echo -n .47  
Read  $PLLSCR4 0x00000000 0x03ff03ff #xxxx xxLL LLLL LLLL xxxx xxLL LLLL LLLL Confirm on PLLS: Initialize Register as in Table 8-1-18
echo -n .48  
Write $PLLFCR5 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program on PLLF: Initialize Register as in Table 8-1-19
echo -n .49  
Read  $PLLFCR5 0x00000000 0xf007000f #LLLL xxxx xxxx xLLL xxxx xxxx xxxx LLLL Confirm on PLLF: Initialize Register as in Table 8-1-19
echo -n .50  
Write $PLLSCR5 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program on PLLS: Initialize Register as in Table 8-1-19
echo -n .51  
Read  $PLLSCR5 0x00000000 0xf007000f #LLLL xxxx xxxx xLLL xxxx xxxx xxxx LLLL Confirm on PLLS: Initialize Register as in Table 8-1-19
echo -n .52  
Write $PLLFCR6 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program on PLLF: Initialize Register as in Table 8-1-20
echo -n .53  
Readw  $PLLFCR6 0x00000000 0x3333ffff #xxLL xxLL xxLL xxLL LLLL LLLL LLLL LLLL Confirm on PLLF: Initialize Register as in Table 8-1-20
echo -n .54  
Write $PLLSCR6 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program on PLLS: Initialize Register as in Table 8-1-20
echo -n .55  
Readw  $PLLSCR6 0x00000000 0x3333ffff #xxLL xxLL xxLL xxLL LLLL LLLL LLLL LLLL Confirm on PLLS: Initialize Register as in Table 8-1-20
echo -n .56  
Write $PLLFCR8 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program on PLLF: Initialize Register as in Table 8-1-22
echo -n .57  
Read  $PLLFCR8 0x00000000  0xc3370000 #LLxx xxLL xxLL xLLL xxxx xxxx xxxx xxxx Confirm on PLLF: Initialize Register as in Table 8-1-22
echo -n .58  
Write $PLLSCR8 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program on PLLS: Initialize Register as in Table 8-1-22
echo -n .59  
Read  $PLLSCR8 0x00000000  0xc3370000 #LLxx xxLL xxLL xLLL xxxx xxxx xxxx xxxx Confirm on PLLS: Initialize Register as in Table 8-1-22
echo -n .60  
Write $PLLFCR9 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program on PLLF: Initialize Register as in Table 8-1-23
echo -n .61  
Read  $PLLFCR9 0x00000000  0xe7300000 #LLLx xLLL xxLL xxxx xxxx xxxx xxxx xxxx Confirm on PLLF: Initialize Register as in Table 8-1-23
echo -n .62  
Write $PLLSCR9 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program on PLLS: Initialize Register as in Table 8-1-23
echo -n .63  
Read  $PLLSCR9 0x00000000  0xe7300000 #LLLx xLLL xxLL xxxx xxxx xxxx xxxx xxxx Confirm on PLLS: Initialize Register as in Table 8-1-23
echo -n .64  
Write $GCR0 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program on all lanes: Initialize Register as in Table 8-1-24
echo -n .65  
Read  $GCR0 0x00000000  0xf0033007 #LLLL xxxx xxxx xxLL xxLL xxxx xxxx xLLL Confirm on all lanes: Initialize Register as in Table 8-1-24
echo -n .66  
Write $TGCR0 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program on all lanes: Initialize Register as in Table 8-1-26
echo -n .67  
Read  $TGCR0 0x00000000  0x9700130b #LxxL xLLL xxxx xxxx xxxL xxLL xxxx LxLL Confirm on all lanes: Initialize Register as in Table 8-1-26
echo -n .68  
Write $TGCR1 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program on all lanes: Initialize Register as in Table 8-1-27
echo -n .69  
Read  $TGCR1 0x00000000  0x893f831f #Lxxx LxxL xxLL LLLL Lxxx xxLL xxxL LLLL Confirm on all lanes: Initialize Register as in Table 8-1-27
echo -n .70  
Write $TGCR2 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program on all lanes: Initialize Register as in Table 8-1-28
echo -n .71  
Read  $TGCR2 0x00000000  0x00337000 #xxxx xxxx xxLL xxLL xLLL xxxx xxxx xxxx Confirm on all lanes: Initialize Register as in Table 8-1-28
echo -n .72  
Write $TECR0 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program on all lanes: Initialize Register as in Table 8-1-29
echo -n .73  
Read  $TECR0 0x00000000  0x708f9f3f #xLLL xxxx Lxxx LLLL LxxL LLLL xxLL LLLL Confirm on all lanes: Initialize Register as in Table 8-1-29
echo -n .74  
Write $TECR1 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program on all lanes: Initialize Register as in Table 8-1-30
echo -n .75  
Read  $TECR1 0x00000000  0xbf008f3f #LxLL LLLL xxxx xxxx Lxxx LLLL xxLL LLLL Confirm on all lanes: Initialize Register as in Table 8-1-30
echo -n .76  
Write $RGCR0 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program on all lanes: Initialize Register as in Table 8-1-32
echo -n .77  
Read  $RGCR0 0x00000000  0x970003b3 #LxxL xLLL xxxx xxxx xxxx xxLL LxLL xxLL Confirm on all lanes: Initialize Register as in Table 8-1-32
echo -n .78  
Write $RGCR1 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program on all lanes: Initialize Register as in Table 8-1-33
echo -n .79  
Read  $RGCR1 0x00000000  0x9777073f #LxxL xLLL xLLL xLLL xxxx xLLL xxLL LLLL Confirm on all lanes: Initialize Register as in Table 8-1-33
echo -n .80  
Write $RECR0 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program on all lanes: Initialize Register as in Table 8-1-34
echo -n .81  
Read  $RECR0 0x00000000  0x9f9f00bf #LxxL LLLL LxxL LLLL xxxx xxxx LLxL LLLL Confirm on all lanes: Initialize Register as in Table 8-1-34
echo -n .82  
Write $RECR1 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program on all lanes: Initialize Register as in Table 8-1-35
echo -n .83  
Read  $RECR1 0x00000000  0x9fbf0000 #LxxL LLLL LxLL LLLL xxxx xxxx xxxx xxxx Confirm on all lanes: Initialize Register as in Table 8-1-35
echo -n .84  
Write $RECR2 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program on all lanes: Initialize Register as in Table 8-1-36
echo -n .85  
Read  $RECR2 0x00000000  0xb3033033 #LxLL xxLL xxxx xxLL xxLL xxxx xxLL xxLL Confirm on all lanes: Initialize Register as in Table 8-1-36
echo -n .86  
Write $RECR3 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program on all lanes: Initialize Register as in Table 8-1-37
echo -n .87  
Read  $RECR3 0x00000000  0x80000000 #Lxxx xxxx xxxx xxxx xxxx xxxx xxxx xxxx Confirm on all lanes: Initialize Register as in Table 8-1-37
echo -n .88  
Write $RECR4 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program on all lanes: Initialize Register as in Table 8-1-38
echo -n .89  
Read  $RECR4 0x00000000  0x0000f000 #xxxx xxxx xxxx xxxx LLLL xxxx xxxx xxxx Confirm on all lanes: Initialize Register as in Table 8-1-38
echo -n .90  
Write $RCCR0 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program on all lanes: Initialize Register as in Table 8-1-39
echo -n .91  
Read  $RCCR0 0x00000000  0xbf008f8f #LLxL LLLL xxxx xxxx Lxxx LLLL Lxxx LLLL Confirm on all lanes: Initialize Register as in Table 8-1-39
echo -n .92  
Write $RCCR1 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program on all lanes: Initialize Register as in Table 8-1-40
echo -n .93  
Read  $RCCR1 0x00000000  0x33338f8f #xxLL xxLL xxLL xxLL Lxxx LLLL Lxxx LLLL Confirm on all lanes: Initialize Register as in Table 8-1-40
echo -n .94  
Write $RCPCR0 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program on all lanes: Initialize Register as in Table 8-1-41
echo -n .95  
Read  $RCPCR0 0x00000000  0x0000b771 #xxxx xxxx xxxx xxxx LLxL xLLL xLLL xxxL Confirm on all lanes: Initialize Register as in Table 8-1-41
echo -n .96  
Write $RSCCR0 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program on all lanes: Initialize Register as in Table 8-1-42
echo -n .97  
Read  $RSCCR0 0x00000000  0xeb8f3333 #LLLx LxLL Lxxx LLLL xxLL xxLL xxLL xxLL Confirm on all lanes: Initialize Register as in Table 8-1-42
echo -n .98  
Write $RSCCR1 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program on all lanes: Initialize Register as in Table 8-1-43
echo -n .99  
Read  $RSCCR1 0x00000000  0x00033333 #xxxx xxxx xxxx xxLL xxLL xxLL xxLL xxLL Confirm on all lanes: Initialize Register as in Table 8-1-43
echo -n .100 
Write $TTLCR0 0x00008000 #0000 0000 0000 0000 1000 0000 0000 0000 Program on all lanes: Initialize Register as in Table 8-1-44
echo -n .101 
Read  $TTLCR0 0x00008000  0x3f778003 #xxLL LLLL xLLL xLLL Hxxx xxxx xxxx xxLL Confirm on all lanes: Initialize Register as in Table 8-1-44
echo -n .102 
Write $TTLCR1 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program on all lanes: Initialize Register as in Table 8-1-45
echo -n .103 
Read  $TTLCR1 0x00000000  0xc07f007f #LLxx xxxx xLLL LLLL xxxx xxxx xLLL LLLL Confirm on all lanes: Initialize Register as in Table 8-1-45
echo -n .104 
Write $TTLCR2 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program on all lanes: Initialize Register as in Table 8-1-46
echo -n .105 
Read  $TTLCR2 0x00000000  0xe07f007f #LLLx xxxx xLLL LLLL xxxx xxxx xLLL LLLL Confirm on all lanes: Initialize Register as in Table 8-1-46
echo -n .106 
Write $TTLCR3 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program on all lanes: Initialize Register as in Table 8-1-47
echo -n .107 
Read  $TTLCR3 0x00000000 0xffffffff #LLLL LLLL LLLL LLLL LLLL LLLL LLLL LLLL Confirm on all lanes: Initialize Register as in Table 8-1-47
echo -n .108 
Write $TCSR0 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program on all lanes: Initialize Register as in Table 8-1-48
echo -n .109 
Read  $TCSR0 0x00000000 0xb0003400 #LxLL xxxx xxxx xxxx xxLL xLxx xxxx xxxx Confirm on all lanes: Initialize Register as in Table 8-1-48
echo -n .110 
Write $TCSR1 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program on all lanes: Initialize Register as in Table 8-1-49
echo -n .111 
Read  $TCSR1 0x00000000 0x0f0f01ff #xxxx LLLL xxxx LLLL xxxx xxxL LLLL LLLL Confirm on all lanes: Initialize Register as in Table 8-1-49
echo -n .112 
Write $TCSR2 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program on all lanes: Initialize Register as in Table 8-1-50
echo -n .113 
Read  $TCSR2 0x00000000 0x83080000 #Lxxx xxLL xxxx Lxxx xxxx xxxx xxxx xxxx Confirm on all lanes: Initialize Register as in Table 8-1-50
echo -n .114 
Write $TCSR3 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program on all lanes: Initialize Register as in Table 8-1-51
echo -n .115 
Read  $TCSR3 0x00000000 0x0ffc000f #xxxx LLLL LLLL LLxx xxxx xxxx xxxx LLLL Confirm on all lanes: Initialize Register as in Table 8-1-51
echo -n .116 
Write $TCSR4 0x00000000 #0000 0000 0000 0000 0000 0000 0000 0000 Program on all lanes: Initialize Register as in Table 8-1-52
echo -n .117 
Read  $TCSR4 0x00000000 0xf0000000 #LLLL xxxx xxxx xxxx xxxx xxxx xxxx xxxx Confirm on all lanes: Initialize Register as in Table 8-1-52
echo -n .118 
Write $RSTCTL 0x00000010 #0000 0000 0000 0000 0000 0000 0001 0000 Program on block: According to Table 8-1-1
echo -n .119 
Read  $RSTCTL 0x00000010 0x00000010 #xxxx xxxx xxxx xxxx xxxx xxxx xxxH xxxx Confirm on block: According to Table 8-1-1
echo -n .120 
sleep 0.1 # Wait $1 Wait 200 ns for Analog to power up from lynx_en
echo -n .121 
Write $LCAPCR0 0x00000020 #0000 0000 0000 0000 0000 0000 0010 0000 Program: According to Table 8-1-4
echo -n .122 
Read  $LCAPCR0 0x00000020 0x00000020 #xxxx xxxx xxxx xxxx xxxx xxxx xxHx xxxx Confirm: According to Table 8-1-4
echo -n .123 
Write $RCAPCR0 0x00000020 #0000 0000 0000 0000 0000 0000 0010 0000 Program: According to Table 8-1-8
echo -n .124 
Read  $RCAPCR0 0x00000020 0x00000020 #xxxx xxxx xxxx xxxx xxxx xxxx xxHx xxxx Confirm: According to Table 8-echo -n .1-8

echo -n .125 
sleep 0.1 # Wait 1 Wait 800 ns for Impedance Calibration to stabilize

echo
echo SUCCESS

