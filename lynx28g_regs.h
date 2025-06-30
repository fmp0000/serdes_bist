/* SPDX-License-Identifier: BSD-3-Clause */

/*
 * Copyright 2024 NXP
 */


#define RSTCTL 0x000
#define GR0 0x004
#define TCR0 0x008
#define LCAPCR0 0x020
#define LCAPCR1 0x024
#define LCAPCR2 0x028
#define LCAPCR3 0x02C
#define RCAPCR0 0x040
#define RCAPCR1 0x044
#define RCAPCR2 0x048
#define RCAPCR3 0x04C

#define PLLFRSTCTL 0x400 
#define PLLFCR0 0x404 
#define PLLFCR1 0x408 
#define PLLFCR2 0x40C 
#define PLLFCR3 0x410 
#define PLLFCR4 0x414 
#define PLLFCR5 0x418 
#define PLLFCR6 0x41C 
#define PLLFCR7 0x420 
#define PLLFCR8 0x424 
#define PLLFCR9 0x428 
#define PLLFSSCR0 0x430 
#define PLLFSSCR1 0x434 
#define PLLFSSCR2 0x438 
#define PLLFSSCR3 0x43C 
#define PLLFCB0 0x4F0 
#define PLLFCB1 0x4F4 

#define PLLSRSTCTL 0x500 
#define PLLSCR0 0x504 
#define PLLSCR1 0x508 
#define PLLSCR2 0x50C 
#define PLLSCR3 0x510 
#define PLLSCR4 0x514 
#define PLLSCR5 0x518 
#define PLLSCR6 0x51C 
#define PLLSCR7 0x520 
#define PLLSCR8 0x524 
#define PLLSCR9 0x528 
#define PLLSSSCR0 0x530 
#define PLLSSSCR1 0x534 
#define PLLSSSCR2 0x538 
#define PLLSSSCR3 0x53C 
#define PLLSCB0 0x5F0 
#define PLLSCB1 0x5F4 

#define LNmGCR0(n) (0x800+ n*0x100)
#define LNmTRSTCTL(n) (0x820+ n*0x100)
#define LNmTGCR0(n) (0x824+ n*0x100)
#define LNmTGCR1(n) (0x828+ n*0x100)
#define LNmTGCR2(n) (0x82C+ n*0x100)
#define LNmTECR0(n) (0x830+ n*0x100)
#define LNmTECR1(n) (0x834+ n*0x100)
#define LNmRRSTCTL(n) (0x840+ n*0x100)
#define LNmRGCR0(n) (0x844+ n*0x100)
#define LNmRGCR1(n) (0x848+ n*0x100)
#define LNmRECR0(n) (0x850+ n*0x100)
#define LNmRECR1(n) (0x854+ n*0x100)
#define LNmRECR2(n) (0x858+ n*0x100)
#define LNmRECR3(n) (0x85C+ n*0x100)
#define LNmRECR4(n) (0x860+ n*0x100)
#define LNmRCCR0(n) (0x868+ n*0x100)
#define LNmRCCR1(n) (0x86C+ n*0x100)
#define LNmRCPCR0(n) (0x870+ n*0x100)
#define LNmRSCCR0(n) (0x874+ n*0x100)
#define LNmRSCCR1(n) (0x878+ n*0x100)
#define LNmTTLCR0(n) (0x880+ n*0x100)
#define LNmTTLCR1(n) (0x884+ n*0x100)
#define LNmTTLCR2(n) (0x888+ n*0x100)
#define LNmTTLCR3(n) (0x88C+ n*0x100)
#define LNmTCSR0(n) (0x8A0+ n*0x100)
#define LNmTCSR1(n) (0x8A4+ n*0x100)
#define LNmTCSR2(n) (0x8A8+ n*0x100)
#define LNmTCSR3(n) (0x8AC+ n*0x100)
#define LNmTCSR4(n) (0x8B0+ n*0x100)
#define LNmRXCB0(n) (0x8C0+ n*0x100)
#define LNmRXCB1(n) (0x8C4+ n*0x100)
#define LNmRXSS0(n) (0x8D0+ n*0x100)
#define LNmRXSS1(n) (0x8D4+ n*0x100)
#define LNmRXSS2(n) (0x8D8+ n*0x100)
#define LNmTXCB0(n) (0x8E0+ n*0x100)
#define LNmTXCB1(n) (0x8E4+ n*0x100)
#define LNmTXSS0(n) (0x8F0+ n*0x100)
#define LNmTXSS1(n) (0x8F4+ n*0x100)
#define LNmTXSS2(n) (0x8F8+ n*0x100)

typedef struct lynx28_pattern_s {
    uint32_t msg;
    char text[100];
} lynx28_pattern_t;

const lynx28_pattern_t lynx28_patterns[] ={
{ 0b00000 , "Mission mode - no pattern "},
{ 0b00001 , "HFTP (PG/PC)              "},
{ 0b00010 , "Nyquist/2 (PG/PC)         "},
{ 0b00011 , "LFTP (PG/PC)              "},
{ 0b00100 , "MFTP (PG/PC)              "},
{ 0b00101 , "SLBP (PG/PC)              "},
{ 0b00110 , "ASLBP (PG/PC)             "},
{ 0b00111 , "XAUI CRPAT (PG/PC)        "},
{ 0b01000 , "XAUI CJTPAT (PG/PC        "},
{ 0b01001 , "CRPAT (PG/PC)             "},
{ 0b01010 , "CJPAT (PG/PC)             "},
{ 0b01011 , "All 0 (PG)                "},
{ 0b01100 , "All 1 (PG)                "},
{ 0b01101 , "R128 (PG)                 "},
{ 0b01110 , "PRBS9 (PG/PC)             "},
{ 0b01111 , "PRBS7 (PG/PC)             "},
{ 0b10000 , "JTAG RX test (PG)         "},
{ 0b10001 , "PRBS11 (PG/PC)            "},
{ 0b10010 , "CDR stressor (PG)         "},
{ 0b10011 , "TOTZ (PG)                 "},
{ 0b10100 , "R64 (PG)                  "},
{ 0b10101 , "Reserved                  "},
{ 0b10110 , "PRBS31 (PG/PC)            "},
{ 0b10111 , "MFTP_h (PG/PC)            "},
{ 0b11000 , "MFTP_q (PG/PC)            "},
{ 0b11001 , "Reserved                  "},
{ 0b11010 , "PSSPR (PG/PC)             "},
{ 0b11011 , "SATA LBP (PG/PC)          "},
{ 0b11100 , "SATA LTDP (PG/PC)         "},
{ 0b11101 , "SATA HTDP (PG/PC)         "},
{ 0b11110 , "SATA LFSCP (PG/PC)        "},
{ 0b11111 , "TX TAP tester (PG)        "},
{ 0x20, "MAX_CODE_TRACE"}
};

//https://github.com/nxp-qoriq/linux/blob/lf-6.12.y/drivers/phy/freescale/phy-fsl-lynx-28g.c#L620
// linux-lts-nxp/drivers/phy/freescale/phy-fsl-lynx-xgkr-algorithm.c
// linux-lts-nxp/drivers/phy/freescale/phy-fsl-lynx-28g.c
// Protocol 				TEQ_TYPE 	SGN_PREQ  RATIO_PREQ  SGN_PST1Q RATIO_PST1Q ADPT_EQ   AMP_RED
// PCIe gen3 - 8G           10          1         0           1         0 1100      11 0000   00 0000
// CAUI4 C2M - 25.78125G     1          1         10          1         0 0111      11 0000   00 0000
// CAUI4 C2C - 25.78125G     1          1         10          1         0 0111      11 0000   10 0000

// Jon Burnett <jon.burnett@nxp.com> :
// For IBIS-AMI simulation, often would see where we did not need strong TX EQ. RX EQ usually did most of the work.
// Solution might depend on their channels – how much insertion loss.  TX EQ might be needed if there is more insertion loss.  
// Seems like RX EQ is good for 15-20 dB of insertion loss compensation?  Think that was a CAUI spec we relied on at one point.
// Not sure if the SERDES protocols being used will restrict options for TX EQ settings?
// IF wanted to try a basic set of TX EQ settings, would try 
// -	No TX EQ
// -	Minimal pre-cursor only
// -	Minimal post-cursor only 
// -	Minimal pre-cursor + minimal post-cursor.
// -	Medium pre-cursor only
// -	Medium post-cursor only 
// -	Medium pre-cursor + Medium post-cursor.
// Maybe that smaller subset gets some results from SERDES tool to get an idea how TX EQ is helping or hurting.  

// #### TX Equalization ####
// 830h SerDes Lane m TX Equalization Register 0 (LNATECR0) 
// 834h SerDes Lane m TX Equalization Register 1 (LNATECR1)
//
// > TEQ_TYPE     // LNaTECR0 mask 0x70000000
//              // Transmit Equalization type selection  
//              // • 000 = No TX Equalization
//              // • 001 = 2 levels of TX Equalization (Main +1 post-cursor)
//              // • 010 = 3 levels of TX Equalization (Main +1 pre-cursor and +1 post-cursor)
// > pre-cursor
//
//   SGN_PREQ     // LNaTECR0 mask 0x00800000
//                // Sets polarity of pre-cursor ratio in dB 
//                //  • 0 = Negative sign
//                //  • 1 = Positive sign
//   RATIO_PREQ   // LNaTECR0 mask 0x000f0000
//                //Ratio of full swing transition bit to precursor )
//                // • Integer value in the range [0, 12]
// > post cursor
//
//   SGN_PST1Q    // LNaTECR0 mask 0x00008000
//                // Sets polarity of post-cursor ratio in dB  
//                // • 0 = Negative sign
//                // • 1 = Positive sign
//   RATIO_PST1Q  // LNaTECR0 mask 0x00001F00
//                // Ratio of full swing transition bit to postcursor 
//                // • Integer value in the range [0, 16]
// > post cursor
//
//   ADPT_EQ      // LNaTECR0 mask 0x0000003F
//                // Total number of main drivers
//                // • 11 0000b (48d) = Maximum value
//                // • 01 0100b (20d) = Minimum value
// 
//   AMP_RED      // Output amplitude, Integer value in the range [0, 13] 


// #### RX Equalization ####
// 850h SerDes Lane m RX Equalization Register 0 (LNARECR0) 
// 854h SerDes Lane m RX Equalization Register 1 (LNARECR1) 
// 858h SerDes Lane m RX Equalization Register 2 (LNARECR2) 
// 85Ch SerDes Lane m RX Equalization Register 3 (LNARECR3) 
// 860h SerDes Lane m RX Equalization Register 4 (LNARECR4)
//   EQ_GAINK2_HF_OV ;   // LNmRECR0 enable 0x80000000 mask 0x1F000000
//                       // Lane adaptive equalization gaink2 
//                       // • 00000b - Maximum equalization
//                       // • 11111b - Minimum equalization
//   EQ_GAINK3_MF_OV ;   // LNmRECR0 enable 0x00800000 mask 0x001F0000
//                       // Lane adaptive equalization gaink3 
//                       // • 00000b - Maximum equalization
//                       // • 11111b - Minimum equalization
//   EQ_GAINK4_LF_OV;    // LNmRECR0 enable 0x00000080 disable 0x00000040 mask 0x0000001F
//                       // Lane adaptive equalization gaink4 
//                       // • 00000b - Maximum equalization
//                       // • 11111b - Minimum equalization
//   EQ_BLW_OV;          // LNaRECR1 enable 0x80000000 mask 0x1F000000
//                       // Lane adaptive equalization BLW
//                       // • Recommended value: 00000
//   EQ_OFFSET_OV;       // LNaRECR1 enable 0x00800000 mask 0x001F0000
//                       // Lane adaptive equalization "offset"
//                       // • Recommended value: 011111
//                       // LNmRECR2[EQ_OFFSET_RNG_DBL] doubles this offset. 
//                       // Recommended value is 0 except for PCI/10G/25G/100G
//                       // • 000000b - Maximum positive offset
//                       // • 011111b - No offset
//                       // • 111111b - Maximum negative offset
//   EQ_BOOST;           // LNmRECR2 mask 0x03000000
//                       // Equalization boost (not an override signal)
//                       // • Recommended value: 00
//   EQ_ZERO;            // LNmRECR2 mask 0x00030000
//                       // RX adaptive equalization zero frequency adjustment
//                       // • Recommended value: 00
//   EQ_IND;             // LNmRECR2 mask 0x00003000
//                       // RX adaptive equalization inductor adjustment
//                       // • Recommended value: 00
//   EQ_BIN_DATA_AVG_TC; // LNmRECR2 mask 0x00000030
//                       // Bin data average time constant
//                       // • Recommended value: 00
//   SPARE_IN;           // LNmRECR2 mask 0x00000003
//                       // Spare inputs
//                       // • Recommended value: 00
//   ENTER_IDLE_FLT_SEL; // LNmRGCR1 mask 0x07000000
//                       // Used to filter the results from receiver's loss of signal detector.
//                       // • Recommended value: 000, except for sata/pci2.5/1GSGMII
//   EXIT_IDLE_FLT_SEL;  // LNmRGCR1 mask 0x00700000
//                       // This signal determines when to leave idle state.
//                       // • Recommended value: 000, except for sata/pci2.5/1GSGMII
//   DATA_LOST_TH_SEL;   // LNmRGCR1 mask 0x00070000
//                       // Receiver electrical idle detection threshold.
//                       // • Recommended value: 000, except for sata/pci2.5/1GSGMII
//   EXT_REC_CLK_SEL;    // LNmRGCR1 mask 0x00000700
//                       // Divider value for external recovered clock.
                             // • Recommended value: 000, 

typedef struct s_eq_param {
	char reg_name[128];
	int32_t reg_offset;
	char field_name[128];
	uint32_t mask;
	uint32_t bit_shift;
	uint32_t val_min;
	uint32_t val_max;
} t_eq_param;
