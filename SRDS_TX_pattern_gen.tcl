###############################################################################################
#
#  SRDS_TX_pattern_gen.tcl  - Rahul Nehlani 
###############################################################################################
# This script generates TX patterns on Geul SerDes.
# Running the Tx pattern generation scenario drives the SerDes module 
# to generate a specific pattern (set up by the user) on the Tx side 
# of the lane that is being verified.
###############################################################################################

proc tx_pattern_gen { lane { tx_pattern 10} {loopback 0}} { 

	set lane [string toupper $lane]
	switch $lane {
		A { set lane_no 0 }
		B { set lane_no 1 }
		C { set lane_no 2 }
		D { set lane_no 3 }
		E { set lane_no 4 }
		F { set lane_no 5 }
		G { set lane_no 6 }
		H { set lane_no 7 }
		default { error "Enter correct lane alphabet eg: a,b,c,etc."}
	}
	
	#Configuring chain
	ccs::config_chain {geul sap2}
	
	#SAP Chain position for Geul
	set chain_pos 21
	
	# SerDes Addr = CCSR_BASE_ADDR + SERDES_OFFSET
	#            = 0xF800_0000 + 0x31E_0000
	#            = 0xFB1E_0000
	set base_addr 0xFB1E0000
	set RSTCTL  [expr $base_addr + 0x000 ]
	set GR0     [expr $base_addr + 0x004 ]
	set TCR0    [expr $base_addr + 0x008 ]
	set LCAPCR0 [expr $base_addr + 0x020 ]
	set LCAPCR1 [expr $base_addr + 0x024 ]
	set LCAPCR2 [expr $base_addr + 0x028 ]
	set LCAPCR3 [expr $base_addr + 0x02C ]
	set RCAPCR0 [expr $base_addr + 0x040 ]
	set RCAPCR1 [expr $base_addr + 0x044 ]
	set RCAPCR2 [expr $base_addr + 0x048 ]
	set RCAPCR3 [expr $base_addr + 0x04C ]
	set LNmGCR0    [expr $base_addr + 0x800 + ($lane_no * 0x100)]
	set LNmTRSTCTL [expr $base_addr + 0x820 + ($lane_no * 0x100)]
	set LNmTGCR0   [expr $base_addr + 0x824 + ($lane_no * 0x100)]
	set LNmTGCR1   [expr $base_addr + 0x828 + ($lane_no * 0x100)]
	set LNmTGCR2   [expr $base_addr + 0x82C + ($lane_no * 0x100)]
	set LNmTECR0   [expr $base_addr + 0x830 + ($lane_no * 0x100)]
	set LNmTECR1   [expr $base_addr + 0x834 + ($lane_no * 0x100)]
	set LNmRRSTCTL [expr $base_addr + 0x840 + ($lane_no * 0x100)]
	set LNmRGCR0   [expr $base_addr + 0x844 + ($lane_no * 0x100)]
	set LNmRGCR1   [expr $base_addr + 0x848 + ($lane_no * 0x100)]
	set LNmRECR0   [expr $base_addr + 0x850 + ($lane_no * 0x100)]
	set LNmRECR1   [expr $base_addr + 0x854 + ($lane_no * 0x100)]
	set LNmRECR2   [expr $base_addr + 0x858 + ($lane_no * 0x100)]
	set LNmRECR3   [expr $base_addr + 0x85C + ($lane_no * 0x100)]
	set LNmRECR4   [expr $base_addr + 0x860 + ($lane_no * 0x100)]
	set LNmRCCR0   [expr $base_addr + 0x868 + ($lane_no * 0x100)]
	set LNmRCCR1   [expr $base_addr + 0x86C + ($lane_no * 0x100)]
	set LNmRCPCR0  [expr $base_addr + 0x870 + ($lane_no * 0x100)]
	set LNmRSCCR0  [expr $base_addr + 0x874 + ($lane_no * 0x100)]
	set LNmRSCCR1  [expr $base_addr + 0x878 + ($lane_no * 0x100)]
	set LNmTTLCR0  [expr $base_addr + 0x880 + ($lane_no * 0x100)]
	set LNmTTLCR1  [expr $base_addr + 0x884 + ($lane_no * 0x100)]
	set LNmTTLCR2  [expr $base_addr + 0x888 + ($lane_no * 0x100)]
	set LNmTTLCR3  [expr $base_addr + 0x88C + ($lane_no * 0x100)]
	set LNmTCSR0  [expr $base_addr + 0x8A0 + ($lane_no * 0x100) ]
	set LNmTCSR1  [expr $base_addr + 0x8A4 + ($lane_no * 0x100) ]
	set LNmTCSR2  [expr $base_addr + 0x8A8 + ($lane_no * 0x100) ]
	set LNmTCSR3  [expr $base_addr + 0x8AC + ($lane_no * 0x100) ]
	set LNmTCSR4  [expr $base_addr + 0x8B0 + ($lane_no * 0x100) ]
	set LNmRXCB0  [expr $base_addr + 0x8C0 + ($lane_no * 0x100) ]
	set LNmRXCB1  [expr $base_addr + 0x8C4 + ($lane_no * 0x100) ]
	set LNmRXSS0  [expr $base_addr + 0x8D0 + ($lane_no * 0x100) ]
	set LNmRXSS1  [expr $base_addr + 0x8D4 + ($lane_no * 0x100) ]
	set LNmRXSS2  [expr $base_addr + 0x8D8 + ($lane_no * 0x100) ]
	set LNmTXCB0  [expr $base_addr + 0x8E0 + ($lane_no * 0x100) ]
	set LNmTXCB1  [expr $base_addr + 0x8E4 + ($lane_no * 0x100) ]
	set LNmTXSS0  [expr $base_addr + 0x8F0 + ($lane_no * 0x100) ]
	set LNmTXSS1  [expr $base_addr + 0x8F4 + ($lane_no * 0x100) ]
	set LNmTXSS2  [expr $base_addr + 0x8F8 + ($lane_no * 0x100) ]

	
	# Implement following procedure from 28G_Lynx_Compliance_Test_v2.6.pdf 
	# 4.3.1 Block Initialization/Reset
	# ccs::write_mem $chain_pos $TCR0       4 0 0x00000000
	# ccs::write_mem $chain_pos $TCR0       4 0 0x80000000
	# ccs::write_mem $chain_pos $RSTCTL     4 0 0x00000000
	# ccs::write_mem $chain_pos $LNmTRSTCTL 4 0 0x00000000
	# ccs::write_mem $chain_pos $LNmRRSTCTL 4 0 0x00000000
	# ccs::write_mem $chain_pos $LNmGCR0    4 0 0x00000000
	# ccs::write_mem $chain_pos $LNmTGCR0   4 0 0x00000000
	# ccs::write_mem $chain_pos $LNmTGCR1   4 0 0x00000000
	# ccs::write_mem $chain_pos $LNmTGCR2   4 0 0x00000000
	# ccs::write_mem $chain_pos $LNmRGCR0   4 0 0x00000000
	# ccs::write_mem $chain_pos $LNmRGCR1   4 0 0x00000000
	# ccs::write_mem $chain_pos $RSTCTL      4 0 0x00000010 
	# after 1000
	# ccs::write_mem $chain_pos $LCAPCR0     4 0 0x00000020
	# ccs::write_mem $chain_pos $RCAPCR0     4 0 0x00000020


	# Implement following procedure from 28G_Lynx_Compliance_Test_v2.6.pdf
	# 8.1.4.1 SerDes Receiver Digital Loopback BIST Procedure using MFTP including Initialization
	# 8.1.4.2 SerDes Receiver External Loopback BIST Procedure using MFTP including Initializatioputs "Pattern generation - Started"
	ccs::write_mem $chain_pos $LNmTCSR4  4 0  0x00000000 
	ccs::write_mem $chain_pos $LNmTCSR2  4 0  0x00000000 
	ccs::write_mem $chain_pos $TCR0      4 0  0x80000000
	ccs::write_mem $chain_pos $LNmGCR0   4 0  0x00000002
	ccs::write_mem $chain_pos $LNmTRSTCTL 4 0  0x00000100
	ccs::write_mem $chain_pos $LNmRRSTCTL 4 0  0x00000000
	ccs::write_mem $chain_pos $LNmTCSR0   4 0  [expr $loopback*0x10000000 + 0x80000000] 
	ccs::write_mem $chain_pos $LNmTCSR1 4 0  0x05000000
	ccs::write_mem $chain_pos $LNmTCSR3 4 0  [expr $tx_pattern*0x100000 + 0x0000000f]
	ccs::write_mem $chain_pos $LNmTRSTCTL 4 0  0x00000110
	ccs::write_mem $chain_pos $LNmRRSTCTL 4 0  0x00000010 
	ccs::write_mem $chain_pos $LNmTCSR3   4 0  0x00a8000f
	ccs::write_mem $chain_pos $LNmTRSTCTL 4 0  0x00000130
	ccs::write_mem $chain_pos $LNmTRSTCTL 4 0  0x00000030
	ccs::write_mem $chain_pos $LNmRRSTCTL 4 0  0x00000030
	
	after 1000
	
	# start pattern checker error count 
	ccs::write_mem $chain_pos $LNmTCSR3 4 0 0x02ac000f
	
	while {1} {
	gets stdin key
	if {$key == 0} {break}
	echo [format "SerDes Lane ${lane} LNmRRSTCTL = 0x%08x" [ccs::read_mem $chain_pos $LNmRRSTCTL 4 0 1]]
	echo [format "SerDes Lane ${lane} LNmTCSR3 = 0x%08x"   [ccs::read_mem $chain_pos $LNmTCSR3 4 0 1]]
	}

}