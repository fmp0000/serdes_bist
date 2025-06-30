/* SPDX-License-Identifier: BSD-3-Clause */

/*
 * Copyright 2024 NXP
 */

#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <inttypes.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <sys/timerfd.h>
#include <sys/mman.h>
#include <errno.h>
#include <stdbool.h>
#include <pthread.h>
#include <sched.h>
#include <assert.h>
#include <semaphore.h>
#include <signal.h>
#include <argp.h>
#include <ncurses.h>

#include "lynx28g_regs.h"
#include "lx2160a_regs.h"

// Defines
#define SNAP_LOOP 4000
#define SNAP_LOOP_SIZE32 10

// extern
void hexdump(const void *ptr, size_t sz);

// Globals
uint32_t *v_ccsr; 
uint32_t *v_ccsr_serdes; 
char filename[255];
volatile uint32_t running;

//define


// Equalization parameters
#define MAX_PARAM 25
t_eq_param tx_rx_eq_param[MAX_PARAM]= {
	{"LNmTECR0",	0x30,	"TX: EQ_TYPE  ",			0x70000000, 28,	0,	0b010	},
	{"LNmTECR0",	0x30,	"TX: SGN_PREQ ",			0x00800000, 23,	0,	1		},
	{"LNmTECR0",	0x30,	"TX: EQ_PREQ  ",			0x000F0000, 16,	0,	0b1111	},
	{"LNmTECR0",	0x30,	"TX: SGN_PST1Q",			0x00008000, 15,	0,	1		},
	{"LNmTECR0",	0x30,	"TX: EQ_PST1Q ",			0x00001F00,  8,	0,	0b11111	},
	{"LNmTECR0",	0x30,	"TX: AMP_RED  ",			0x0000003F,  0,	0,	0b111111},
	{"LNmTECR1",	0x34,	"TX: ADPT_EQ_DIS",			0x80000000, 31,	0,	1		},
	{"LNmTECR1",	0x34,	"TX: ADPT_EQ  	",			0x3F000000, 24,	0,	0b111111},
	{"LNARECR0",	0x50,	"RX: EQ_GAINK2_HF_OV_EN",	0x80000000, 31,	0,	1		},
	{"LNARECR0",	0x50,	"RX: EQ_GAINK2_HF_OV   ",	0x1F000000, 24,	0,	0b11111	},
	{"LNARECR0",	0x50,	"RX: EQ_GAINK3_MF_OV_EN",	0x00800000, 23,	0,	1		},
	{"LNARECR0",	0x50,	"RX: EQ_GAINK3_MF_OV   ",	0x001f0000, 16,	0,	0b11111	},
	{"LNARECR0",	0x50,	"RX: EQ_GAINK4_LF_OV_EN",	0x00000080, 7,	0,	1		},
	{"LNmRECR1",	0x50,	"RX: EQ_GAINK4_LF_OV   ",	0x0000001F, 0,	0,	0b11111	},
	{"LNmRECR1",	0x54,	"RX: EQ_BLW_OV_EN      ",	0x80000000, 31,	0,	1		},
	{"LNmRECR1",	0x54,	"RX: EQ_BLW_OV ",			0x3F000000, 24,	0,	0b111111},
	{"LNmRECR1",	0x54,	"RX: EQ_OFFSET_OV_EN   ",	0x00800000, 23,	0,	1		},
	{"LNmRECR1",	0x54,	"RX: EQ_OFFSET_OV",			0x003F0000, 16,	0,	0b111111},
	{"LNaRECR2",	0x58,	"RX: EQ_OFFSET_RNG_DBL ",	0x80000000, 31,	0,			},
	{"LNaRECR2",	0x58,	"RX: EQ_BOOST",				0x30000000, 28,	0,	0b11	},
	{"LNaRECR2",	0x58,	"RX: EQ_BLW_SEL ",			0x03000000, 24,	0,	0b11	},
	{"LNaRECR2",	0x58,	"RX: EQ_ZERO ",				0x00030000, 16,	0,	0b11	},
	{"LNaRECR2",	0x58,	"RX: EQ_IND  ",				0x00003000, 12,	0,	0b11	},
	{"LNaRECR2",	0x58,	"RX: EQ_BIN_DATA_AVG_TC",	0x00000030,  4,	0,	0b01	},
	{"LNaRECR2",	0x58,	"RX: SPARE_IN  ",			0x00000003,  0,	0,	0b01	},
};

// Routines
int map_physical_regions(void)
{
	int devmem_fd;
	//void *scr_p;
	//uint32_t mapsize;
	//uint64_t k_page;

	/*
	* map memory regions
	*/

	devmem_fd = open("/dev/mem", O_RDWR);
	if (-1 == devmem_fd) {
		perror("/dev/mem open failed");
		return -1;
	}

	v_ccsr = mmap(NULL, CCSR_SIZE, PROT_READ | PROT_WRITE,
			MAP_SHARED, devmem_fd, CCSR_ADDR);
	if (v_ccsr == MAP_FAILED) {
		perror("Mapping v_ccsr failed\n");
		return -1;
	}
	
	return 0;
}

uint64_t read_core_cyclic_counter() 
{
	uint64_t time;
	asm volatile("isb;mrs %0, pmccntr_el0" : "=r"(time));
	return time;
}

void terminate_process(int sig)
{
     running = 0;
}

void sigusr1_process(int sig)
{
    fflush(stdout);
}


void print_cmd_help(void)
{
	fprintf(stderr, "\n+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
	fprintf(stderr, "\n|    serdes_test");
	fprintf(stderr, "\n|");
	fprintf(stderr, "\n| ./serdes_test -p <pattern 0-31> -s <serdes 0-2> -l <lane 0-7> -f <file name> -d -m -M <mask lane> -w <if_width>");
	fprintf(stderr, "\n|");
	fprintf(stderr, "\n|\t-h	help");
	fprintf(stderr, "\n| Trace");
	fprintf(stderr, "\n|\t-h	help");
	fprintf(stderr, "\n|\t-p	pattern , default 0xa 01010b - CJPAT (PG/PC)");
	fprintf(stderr, "\n|\t-s	serdes block");
	fprintf(stderr, "\n|\t-L	digital loopback ");
	fprintf(stderr, "\n|\t-i	re-init seredes and pll ");
	fprintf(stderr, "\n|\t-M	lanes mask 0x1=A");
	fprintf(stderr, "\n|\t-w	if_width , default 2 (PCIe)");
	fprintf(stderr, "\n|\t-o	Observation");
	fprintf(stderr, "\n| if_width :"         );
	fprintf(stderr, "\n| 1: 2x - PCIe (20-bit)"         );
	fprintf(stderr, "\n| 2: 4x - 25G/100G (40-bit)"    );
	fprintf(stderr, "\n| patterns :"         );
	fprintf(stderr, "\n| 1 - HFTP"         );
	fprintf(stderr, "\n| 2 - Nyquist/2"    );
	fprintf(stderr, "\n| 3 - LFTP"         );
	fprintf(stderr, "\n| ..."        );
    fprintf(stderr, "\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n");
	return;
}

// # Implement following procedure from 28G_Lynx_Compliance_Test_v2.6.pdf
// # 4.3.1 Block Initialization/Reset
void serdes_init(int mask)
{
	int lane;
	
	*(volatile uint32_t *)((uint64_t)v_ccsr_serdes + TCR0 ) = 0x00000000;
	*(volatile uint32_t *)((uint64_t)v_ccsr_serdes + TCR0 ) = 0x80000000; /* Program for Lynx Test mode */
	*(volatile uint32_t *)((uint64_t)v_ccsr_serdes + RSTCTL ) = 0x00000000 ;
	for(lane=0;lane<8;lane++){
		if(0!=(mask&(1<<lane))){
			*(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmTRSTCTL(lane) ) = 0x00000000;
			*(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmRRSTCTL(lane) ) = 0x00000000;
			*(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmGCR0(lane) )  =0x00000000 ;
			*(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmTGCR0(lane) ) = 0x00000000 ;
			*(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmTGCR1(lane) ) = 0x00000000 ;
			*(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmTGCR2(lane) ) = 0x00000000 ;
			*(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmRGCR0(lane) ) = 0x00000000 ;
			*(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmRGCR1(lane) ) = 0x00000000 ;
			}
		}
		
	*(volatile uint32_t *)((uint64_t)v_ccsr_serdes + RSTCTL ) = 0x00000010 ;
	sleep(0.1);
	*(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LCAPCR0 ) = 0x00000020;
	*(volatile uint32_t *)((uint64_t)v_ccsr_serdes + RCAPCR0 ) = 0x00000020;
}

// # Implement following procedure from 28G_Lynx_Compliance_Test_v2.6.pdf
// # 8.1.4.1 SerDes Receiver Digital Loopback BIST Procedure using MFTP including Initialization
// # 8.1.4.2 SerDes Receiver External Loopback BIST Procedure using MFTP including Initialization
void serdes_start_bist(uint32_t mask,uint32_t if_width,uint32_t pattern,uint32_t loopback)
{
	int lane;

		for(lane=0;lane<8;lane++){
		if(0!=(mask&(1<<lane))){
			/* Setup lane to run BIST on TX to start data in digital loop back */
			*(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmTCSR4(lane) ) = 0x00000000 ;                  
			*(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmTCSR2(lane) ) = 0x00000000 ;              
			*(volatile uint32_t *)((uint64_t)v_ccsr_serdes + TCR0 )           = 0x80000000;   /* TCR0        Test mode enable for SerDes modules. */
			*(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmGCR0(lane))   = 0x00000000    /* GCR0                                          */
																				+ (if_width << 0) ;  
			*(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmTRSTCTL(lane))= 0x00000100;   /* LNATRSTCTL  Tx to common mode (electrical idle).*/
			*(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmRRSTCTL(lane))= 0x00000000;   /* LNARRSTCTL  Rx lane enable = 0                  */
			*(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmTCSR0(lane)  )= 0x80000000    /* LNATCSR0    Enable observation = 0                 */
																				+ (loopback << 28) ; 
			*(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmTCSR1(lane)  )= 0x05000000;   /* LNATCSR1    SD_TST_SEL 0101b - BIST checker mode*/
			*(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmTCSR3(lane)  )= 0x0000000f    /* LNATCSR3    BIST_TST_CNT_WNDW = 1111b           */
																				+ (pattern << 20) ;    
			*(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmTRSTCTL(lane))= 0x00000110;   /* LNATRSTCTL  cm + Tx lane enable                 */
			*(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmRRSTCTL(lane))= 0x00000010;   /* LNARRSTCTL  Tx lane enable                      */ 
			*(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmTCSR3(lane)  )= 0x00a8000f;   /* LNATCSR3    BIST_PN_GEN_EN TX test pattern      */
			*(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmTRSTCTL(lane))= 0x00000130;   /* LNATRSTCTL  cm + Tx lane enable + RST_B         */
			*(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmTRSTCTL(lane))= 0x00000030;   /* LNATRSTCTL  Tx lane enable + RST_B */
			*(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmRRSTCTL(lane))= 0x00000030;   /* LNARRSTCTL  Tx lane enable + RST_B */
		}
	}
}

int main(int argc, char *argv[])
{
	int32_t c;
	uint32_t lane=0,serdes=0,pattern=0xa,reinit=0;
	uint32_t loopback=0,monitor=0,loop=0,mask=0,if_width=2;


	if(argc<=1){
		print_cmd_help();
		exit(1);
	}
	
	strcpy(filename, "out.bin");

	/* command line parser */
	while ((c = getopt(argc, argv, "p:s:a:f:LmDM:w:di")) != EOF)
	{
		switch (c) {
			case 'h': // help
				print_cmd_help();
				exit(1);
			break;
			case 'p':
				pattern = atoi(optarg);
			break;
			case 's':
				serdes = atoi(optarg);
			break;
			case 'f':
				strcpy(filename, optarg);
			break;
			case 'L':
				loopback=1;
			break;
			case 'm':
				monitor=1;
			break;
			case 'i':
				reinit=1;
			break;
			case 'M':
				mask=strtoull(argv[optind-1], 0, 0);
			break;
			case 'D':
			break;
			case 'd':
			break;
			case 'w':
				if_width=atoi(optarg);
			break;
			default:
				print_cmd_help();
				exit(1);
			break;
		}
	}

	/* configure non blocking getch()*/
	initscr();
	keypad(stdscr, TRUE);
	noecho();
	timeout(1000);

	if(monitor){
		clear();
		move(0,0);
		refresh();
	}

	/*
	* check params
	*/

	 printw("\n########## serdes_bist ####");

	if(serdes>2){
		printw("\nbad serdes id should be 0-2 for serdes1/2/3\n");
		goto exit_on_error;
	}
	printw("\nSerdes%d",serdes+1);
	

	if(mask>0xff){
		printw("\nbad serdes lane mask > 0xff\n");
		goto exit_on_error;
	}
	if(!mask) mask=(1<<lane);
	printw("\n lane mask 0x%02x",mask);


	if(if_width>3){
		printw("\nbad if_width > 3\n");
		goto exit_on_error;
	}
	printw("\n if_width 0x%01x",if_width);

	if(pattern>31){
		printw("\nbad pattern lane mask > 31\n");
		goto exit_on_error;
	}
	printw("\n pattern %d [%s]",pattern,lynx28_patterns[pattern].text);

	 printw("\n########################## ");

	/*
	* map memory regions
	*/
	if (map_physical_regions()) {
		printw("map_physical_regions failed:");
		goto exit_on_error;
	}
	
	/* get serdes block pointer */
	v_ccsr_serdes=(uint32_t *)((uint64_t)v_ccsr + CCSR_SERDES1_OFF + serdes*CCSR_SERDES_SIZE);

	running = 1;
	
	signal(SIGINT, terminate_process);
	signal(SIGTERM, terminate_process);
	signal(SIGUSR1, sigusr1_process);

	/* configure serdes lane */
	if(reinit){
		serdes_init(mask);
	}
	
	/* configure serdes BIST TX/RX */
	serdes_start_bist( mask, if_width, pattern,loopback);

	/* wait time must be added to allow the tracking loop to lock onto the data  */
	sleep(1);

	/* start pattern checker error count */
	for(lane=0;lane<8;lane++){
		if(0!=(mask&(1<<lane))){
			// start 
			*(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmTCSR3(lane)  )= 0x02ac000f;   /* lnx_(m)_bist_start_err_count	LNmTCSR3(n)[BIST_STRT_ERR_CNT]      */
		}
	}

	/* get keyboad entry to change eq param*/
	int param=0,i=0,update=0;
	volatile uint32_t * pReg;
	uint32_t val_field=0,val=0;
	t_eq_param * p_eq_param=&tx_rx_eq_param[0];
	if(monitor){
		while(running){
			/* reset lane if eq changes */
			if(update) {
				update=0;
				for(lane=0;lane<8;lane++){
					if(0!=(mask&(1<<lane))){
						*(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmTRSTCTL(lane))|=0x8000000;
						*(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmRRSTCTL(lane))|=0x8000000;
					}
				}
			}
			
			/* Display eq param and lane status */
			move(8,0);
			refresh();
			i=0;
			/* same eq param for all lanes in mask , display first one*/
			for(lane=0;lane<8;lane++)if(0!=(mask&(1<<lane))) break;
			for(i=0;i<MAX_PARAM;i++){
				p_eq_param=&tx_rx_eq_param[i];
				val=*(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmGCR0(lane)+p_eq_param->reg_offset);
				val=(val&p_eq_param->mask)>>p_eq_param->bit_shift;
				printw("\n[%s] %s=%d",(i==param?"*":" "),p_eq_param->field_name,val);
				refresh();
			}
			printw("\n");
			for(lane=0;lane<8;lane++){
				if(0!=(mask&(1<<lane))){
				loop++;
				printw("\n## Lane %d ## ", lane);
				//print Tx Rx Eq
				printw("\n  %s [0x%08x]:0x%08x","LNmTECR0-1", CCSR_SERDES1_OFF + serdes*CCSR_SERDES_SIZE + LNmTECR0(lane), *(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmTECR0(lane)));
				printw(" 0x%08x", *(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmTECR1(lane)));
				printw("\n  %s [0x%08x]:0x%08x","LNmRECR0-4", CCSR_SERDES1_OFF + serdes*CCSR_SERDES_SIZE + LNmRECR0(lane), *(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmRECR0(lane)));
				printw(" 0x%08x", *(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmRECR1(lane)));
				printw(" 0x%08x", *(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmRECR2(lane)));
				printw(" 0x%08x", *(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmRECR3(lane)));
				printw(" 0x%08x", *(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmRECR4(lane)));
				// print lane status
				val=*(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmRRSTCTL(lane));
				printw("\n> %s [0x%08x]:0x%08x %s","LNmRRSTCTL", CCSR_SERDES1_OFF + serdes*CCSR_SERDES_SIZE + LNmRRSTCTL(lane),val,(val&0x00001000)?"CDR LOCK YES":"CDR LOCK NO");
				val=*(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmTCSR3(lane));
				printw("\n> %s [0x%08x]:0x%08x %s","LNmTCSR3  ", CCSR_SERDES1_OFF + serdes*CCSR_SERDES_SIZE + LNmTCSR3(lane),val,(val&0x00020000)?"BIST SYNC YES":"BIST SYNC NO");
				}
			}
			int c = getch();
			if(c == ERR) continue;
			switch(c) {
				case KEY_DOWN:
					if(param!=(MAX_PARAM-1)) param++;
					break;
				case KEY_UP:
					if(param!=0) param--;
					break;
				case KEY_LEFT:
					p_eq_param=&tx_rx_eq_param[param];
					for(lane=0;lane<8;lane++){
						if(0!=(mask&(1<<lane))){
							pReg=(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmGCR0(lane)+p_eq_param->reg_offset);
							val_field=(*pReg & p_eq_param->mask)>>p_eq_param->bit_shift;
							if(val_field>p_eq_param->val_min) val_field--;
							*pReg=(*pReg&~p_eq_param->mask)|(val_field<<p_eq_param->bit_shift);
						}
					}
					update=1;
					break;
				case KEY_RIGHT:
					p_eq_param=&tx_rx_eq_param[param];
					for(lane=0;lane<8;lane++){
						if(0!=(mask&(1<<lane))){
							pReg=(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmGCR0(lane)+p_eq_param->reg_offset);
							val_field=(*pReg & p_eq_param->mask)>>p_eq_param->bit_shift;
							if(val_field<p_eq_param->val_max) val_field++;
							*pReg=(*pReg&~p_eq_param->mask)|(val_field<<p_eq_param->bit_shift);
						}
					}
					update=1;
					break;
				default:
					break;
			}
		}
		printw("\n");
	}

	endwin();
	return 0;
	
exit_on_error:

	endwin();
	return -1;

}



