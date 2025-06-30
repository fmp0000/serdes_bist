Introduction
============

   serdes_bist is a simple linux user space utility allowing to confiugre LX2160 serdes block
   for BIST testing. The tool will configure transmission of a selectable BIST patternn
   and it will configure accordingly the pattern checker in reception. 
   
   This repository uses the Open Source BSD-3-Clause license for the user space
   libraries and applications. 

usage 
======

root@lx2160aqds:~/serdes_bist# ./serdes_bist -h
	
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
|    serdes_test
|
| ./serdes_test -p <pattern 0-31> -s <serdes 0-2> -M <mask lane> 
|
|       -h      help
| Trace
|       -h      help
|       -p      pattern , default 0xa 01010b - CJPAT (PG/PC)
|       -s      serdes block
|       -L      digital loopback
|       -i      re-init seredes and pll
|       -M      lanes mask 0x1=A
| if_width :
| 1: 2x - PCIe (20-bit)
| 2: 4x - 25G/100G (40-bit)
| patterns :
| 1 - HFTP
| 2 - Nyquist/2
| 3 - LFTP
| ...
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


Build Instructions
==================

make


usage
======

Simple script

root@lx2160aqds:~/serdes_bist# ./serdes-init.sh 0 4
.2.3.4.5.6.7.8.9.10.11.12.13.14.15.16.17.18.19.20.21.22.23.24.25.26.27.28.29.30.31.32.33.34.35.36.37.38.39.40.41.42.43.44.45.46.47.48.49.50.51.52.53
Warning: 0x00300000 & 0x3333ffff differ from 0x00000000
.54.55
Warning: 0x00300000 & 0x3333ffff differ from 0x00000000
.56.57.58.59.60.61.62.63.64.65.66.67.68.69.70.71.72.73.74.75.76.77.78.79.80.81.82.83.84.85.86.87.88.89.90.91.92.93.94.95.96.97.98.99.100.101.102.103.104.105.106.107.108.109.110.111.112.113.114.115.116.117.118.119.120.121.122.123.124.125
SUCCESS
root@lx2160aqds:~/serdes_bist# ./pllf-init-25G-161.13MHz.sh 0 4
.2.3.4.5.6.7.8.9.10.11.12.13.14.15
Warning: 0x00300000 & 0x3333ffff differ from 0x00000000
.16.17.18.19
SUCCESS
root@lx2160aqds:~/serdes_bist# ./pllf-calib-lock.sh 0 4
.2.3.4.5.6.7.8.9.10.11.12.13.14.15
SUCCESS
root@lx2160aqds:~/serdes_bist# ./bist-MFTP.sh 0 4
Arguments wrong.
usage: ./bist.sh <serdes 0-2> <lane 0-7> <digital loopback 0/1>
root@lx2160aqds:~/serdes_bist# ./bist-MFTP.sh 0 4 1
Table 8-8 SerDes Receiver External Loopback BIST using MFTP and Initialization
.2.3.4.5.6.7.8.9.10.11.13.14.15.16.18.19.20.21.22.23.25.26.28.29.30.31.32.33.34.35.37.38.40.41
SUCCESS

Full utility

root@lx2160aqds:~/serdes_bist# resize
root@lx2160aqds:~/serdes_bist# ./serdes_bist -m -M 0xf0 -i 
 
 ########## serdes_bist ####
Serdes1
 lane mask 0xf0
 if_width 0x2
 pattern 10 [CJPAT (PG/PC)             ]
##########################


 recommended values
 Protocol                 TEQ_TYPE    SGN_PREQ  EQ_PREQ  SGN_PST1Q    EQ_PST1Q    ADPT_EQ   AMP_RED
 PCIe gen3 - 8G           10          1         0           1         0 1100      11 0000   00 0000
 CAUI4 C2M - 25.78125G     1          1         10          1         0 0111      11 0000   00 0000
 CAUI4 C2C - 25.78125G     1          1         10          1         0 0111      11 0000   10 0000
 Protocol                 GK2OVD    GK3OVD  GK2OVD_EN  GK3OVD_EN
 PCIe gen3 - 8G           na          na         0           0
 CAUI4 C2M - 25.78125G    na          na         0           0
 CAUI4 C2C - 25.78125G    na          na         0           0

[*] TX: EQ_TYPE  =0
[ ] TX: SGN_PREQ =0
[ ] TX: EQ_PREQ  =0
[ ] TX: SGN_PST1Q=0
[ ] TX: EQ_PST1Q =0
[ ] TX: AMP_RED  =0
[ ] TX: ADPT_EQ_DIS=0
[ ] TX: ADPT_EQ         =0
[ ] RX: EQ_GAINK2_HF_OV_EN=0
[ ] RX: EQ_GAINK2_HF_OV   =0
[ ] RX: EQ_GAINK3_MF_OV_EN=0
[ ] RX: EQ_GAINK3_MF_OV   =0
[ ] RX: EQ_GAINK4_LF_OV_EN=0
[ ] RX: EQ_GAINK4_LF_OV   =0
[ ] RX: EQ_BLW_OV_EN      =0
[ ] RX: EQ_BLW_OV =0
[ ] RX: EQ_OFFSET_OV_EN   =0
[ ] RX: EQ_OFFSET_OV=0
[ ] RX: EQ_OFFSET_RNG_DBL =0
[ ] RX: EQ_BOOST=0
[ ] RX: EQ_BLW_SEL =0
[ ] RX: EQ_ZERO =0
[ ] RX: EQ_IND  =0
[ ] RX: EQ_BIN_DATA_AVG_TC=0
[ ] RX: SPARE_IN  =0

## Lane 4 ##
  LNmTECR0-1 [0x01ea0c30]:0x00000000 0x00000000
  LNmRECR0-4 [0x01ea0c50]:0x00000000 0x00000000 0x00000000 0x171f0000 0x002400c4
> LNmRRSTCTL [0x01ea0c40]:0x000030b0 CDR LOCK YES
> LNmTCSR3   [0x01ea0cac]:0x02ae000f BIST SYNC YES
## Lane 5 ##
  LNmTECR0-1 [0x01ea0d30]:0x00000000 0x00000000
  LNmRECR0-4 [0x01ea0d50]:0x00000000 0x00000000 0x00000000 0x00000000 0x00000165
> LNmRRSTCTL [0x01ea0d40]:0x000030b0 CDR LOCK YES
> LNmTCSR3   [0x01ea0dac]:0x02ac000f BIST SYNC NO
## Lane 6 ##
  LNmTECR0-1 [0x01ea0e30]:0x00000000 0x00000000
  LNmRECR0-4 [0x01ea0e50]:0x00000000 0x00000000 0x00000000 0x1b1f0000 0x001a008b
> LNmRRSTCTL [0x01ea0e40]:0x000030b0 CDR LOCK YES
> LNmTCSR3   [0x01ea0eac]:0x02ae000f BIST SYNC YES
## Lane 7 ##
  LNmTECR0-1 [0x01ea0f30]:0x00000000 0x00000000
  LNmRECR0-4 [0x01ea0f50]:0x00000000 0x00000000 0x00000000 0x191f0000 0x00140006
> LNmRRSTCTL [0x01ea0f40]:0x000030b0 CDR LOCK YES
> LNmTCSR3   [0x01ea0fac]:0x02ae000f BIST SYNC YES



### LA1224RDB_revC PCI testing between LX2160 and LA1224 , 
# LX2160 Serdes 3 x8 PCI
# LA1222 Serdes 1 x8 PCI

insmod /lib/modules/4.19.90-rt35-00053-g35d544f5e57a/extra/pmu_el0_cycle_counter.ko
./serdes_bist

(serdes_bist) 70 % source ././SRDS_TX_pattern_gen.tcl
(serdes_bist) 71 % tx_pattern_gen a 1 


Reference (NXP only)
====================

// pydart
(bin) 49 % source ../../emdefs/setup/lx2160_rev2_0.9rc.tcl
Setting up emdefs...
defineBoard lx21602.0 lx21602.0soc lx2160_soc2.0
switch to sb->sap namespace
Source utilities, DFT scripts
/home/nxp/Freescale/ccs_bld488.0.0.190621/ccs/bin
loading superdiag
cfg file: /home/nxp/Freescale/ccs_bld488.0.0.190621/qds_scripts/cfg/LX2160QDS_LX2160.tcl
emdefs loading Done
__Done__
(bin) 50 % cd /home/nxa15228/SDK/LX2160/git/pydart/dart/hssi/tmt_atx/lx2160/lynx_28G_CTG/28GLCTG_v2.6/28GLCTG_v2.6_tcl/
(28GLCTG_v2.6_tcl) 57 % config cc cwtap:172.16.0.197
(28GLCTG_v2.6_tcl) 58 % ccs::config_chain {lx2160a dap}
(28GLCTG_v2.6_tcl) 59 % ::qds::qds_init
(28GLCTG_v2.6_tcl) 60 % dirty
(28GLCTG_v2.6_tcl) 61 % lynx28g_lx2160_A.1
Object not defined: CCSR_SCFG1_GENERAL_CONFIG_CONTROL
(28GLCTG_v2.6_tcl) 62 % nstree

  lx21602.0_internal
    scan
->    min
    sb
      sap
(28GLCTG_v2.6_tcl) 63 % ns sb->sap
(28GLCTG_v2.6_tcl) 64 % nstree

  lx21602.0_internal
    scan
      min
    sb
->    sap
(28GLCTG_v2.6_tcl) 65 % lynx28g_lx2160_A.1
(28GLCTG_v2.6_tcl) 66 % source Lynx_28G_compliance_procs.tcl



# Serdes 1 lane A  ( 100G )
ns sb->sap
lynx28g_lx2160_A.1      ### Run LX2160 Device specific setup
lynx28g_4.2.2.1    1    ### 4.2.2.1 Single Reference Clock Source and lo_volt_sel Negated Initialization
lynx28g_4.3.1 1         ### 4.3.1 Block Initialization/Reset
lynx28g_5.13.1.1.2 1    ### 5.13.1.1.2 12.890625 GHz Clock Net, 25.78125 GHz VCO3F, 161.1328 MHz Ref, LBW PLLF Setup ( LBW because  PLLFCR1[HI_BW_SEL] PLLaCR1[FRATE_SEL]=5 GHz: 1 )
lynx28g_4.4.2.1    1    ### Initialize/Calibrate PLLF and acquire Lock
lynx28g_7.1.2.1    1 a  ### 7.1.2.2.5 SerDes Setup for PLL Jitter Generation and Transfer Tests using PLLF using 40-bit Interface
lynx28g_4.5.2.1    1 a  ### SerDes TX Lane A Initialization
lynx28g_8.1.4.1    1 a  ### 8.1.4.1 SerDes Receiver Digital Loopback BIST Procedure using MFTP including Initialization


# Serdes 2 lane A  ( PCI )
ns sb->sap
lynx28g_lx2160_A.1     1 ### Run LX2160 Device specific setup
#lynx28g_4.2.1.1    2   1 ### 4.2.1.1 Double Reference Clock Source and lo_volt_sel Negated Initialization
lynx28g_4.3.1 1        1 ### 4.3.1 Block Initialization/Reset
lynx28g_5.3.2.1.1  2   1 ### 5.3.2.1.1 5 GHz Clock Net, 20 GHz VCO1, 100 MHz Ref, HBW PLLS Setup ( LBW because  PLLFCR1[HI_BW_SEL] PLLaCR1[FRATE_SEL]=5 GHz: 1 )
lynx28g_4.4.1.1    2   1 ### 4.4.1.1 PLLS Initialization/Recalibration Procedure
#lynx28g_7.1.2.1    2 a 1 ### 7.1.2.1 SerDes Setup for PLL Jitter Generation and Transfer Tests using PLLS using 20-bit Interface
lynx28g_4.5.2.1    2 a 1 ### SerDes TX Lane A Initialization
lynx28g_8.1.4.1    2 a 1 ### 8.1.4.1 SerDes Receiver Digital Loopback BIST Procedure using MFTP including Initialization