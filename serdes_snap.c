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
	fprintf(stderr, "\n|\t-M	lanes mask 0x1=A");
	fprintf(stderr, "\n|\t-w	if_width , default 2 (PCIe)");
	fprintf(stderr, "\n|\t-o	Observation");
	fprintf(stderr, "\n| if_width :"         );
	fprintf(stderr, "\n| 2 - PCIe (20-bit)"         );
	fprintf(stderr, "\n| 4 - 25G/100G (40-bit)"    );
	fprintf(stderr, "\n| patterns :"         );
	fprintf(stderr, "\n| 1 - HFTP"         );
	fprintf(stderr, "\n| 2 - Nyquist/2"    );
	fprintf(stderr, "\n| 3 - LFTP"         );
	fprintf(stderr, "\n| ..."        );
    fprintf(stderr, "\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n");
	return;
}

int main(int argc, char *argv[])
{
	int32_t c;
	uint32_t lane=0,serdes=0,pattern=0xa;
	uint32_t loopback=0,monitor=0,loop=0,dump=0,mask=0,if_width=2,debug=0;


	if(argc<=1){
		print_cmd_help();
		exit(1);
	}
	
	strcpy(filename, "out.bin");

	/* command line parser */
	while ((c = getopt(argc, argv, "p:s:a:f:LmDM:w:d")) != EOF)
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
			case 'M':
				mask=strtoull(argv[optind-1], 0, 0);
			break;
			case 'D':
				dump=1;
			break;
			case 'd':
				debug=1;
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

	if(monitor){
		debug=0;
	    printf("\033[2J");
		printf("\033[H");
	}

	/*
	* check params
	*/

	printf("\n########## serdes_bist ####");

	if(serdes>2){
		printf("\nbad serdes id should be 0-2 for serdes1/2/3\n");
		exit(-1);
	}
	printf("\nSerdes%d",serdes+1);
	

	if(mask>0xff){
		printf("\nbad serdes lane mask > 0xff\n");
		exit(-1);
	}
	printf("\n lane mask 0x%02x",mask);


	if(if_width>3){
		printf("\nbad if_width > 3\n");
		exit(-1);
	}
	printf("\n if_width 0x%01x",if_width);

	if(pattern>31){
		printf("\nbad pattern lane mask > 31\n");
		exit(-1);
	}
	printf("\n pattern %d [%s]",pattern,lynx28_patterns[pattern].text);

	printf("\n########################## ");

	/*
	* map memory regions
	*/
	if (map_physical_regions()) {
		printf("map_physical_regions failed:");
		exit(-1);
	}
	
	/* get serdes block pointer */
	v_ccsr_serdes=(uint32_t *)((uint64_t)v_ccsr + CCSR_SERDES1_OFF + serdes*CCSR_SERDES_SIZE);

	running = 1;
	if(!mask) mask=(1<<lane);
	
	signal(SIGINT, terminate_process);
	signal(SIGTERM, terminate_process);
	signal(SIGUSR1, sigusr1_process);

	for(lane=0;lane<8;lane++){
		if(0!=(mask&(1<<lane))){

			if(debug){
				printf("\n BEFORE serdes%d lane%d (0x%08x) regs :\n",serdes,lane,CCSR_SERDES1_OFF + serdes*CCSR_SERDES_SIZE + LNaGCR0(lane));
				hexdump((const void *)(uint64_t)v_ccsr_serdes + LNaGCR0(lane),0x40);
			}

			/* Setup lane to run BIST on TX to start data in digital loop back */
			*(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmTCSR4(lane) ) = 0x00000000 ;                  
			*(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmTCSR2(lane) ) = 0x00000000 ;              
			*(volatile uint32_t *)((uint64_t)v_ccsr_serdes + TCR0 )           = 0x80000000;   /* TCR0        Test mode enable for SerDes modules. */
			*(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNaGCR0(lane))   = 0x00000000    /* GCR0                                          */
			                                                                    + (if_width << 0) ;  
			*(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmTRSTCTL(lane))= 0x00000100;   /* LNATRSTCTL  Tx to common mode (electrical idle).*/
			*(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmRRSTCTL(lane))= 0x00000000;   /* LNARRSTCTL  Rx lane enable = 0                  */
			*(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmTCSR0(lane)  )= 0x80000000    /* LNATCSR0    Enable observation                  */
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

			if(debug){
				printf("\n AFTER serdes%d lane%d (0x%08x) regs :\n",serdes,lane,CCSR_SERDES1_OFF + serdes*CCSR_SERDES_SIZE + LNaGCR0(lane));
				hexdump((const void *)(uint64_t)v_ccsr_serdes + LNaGCR0(lane),0x40);
			}
		}
	}




	/* dump or monitor registers*/
	if(monitor){
		while(running){
			//printf("\033[H");
			printf("\033[10;1H");

			for(lane=0;lane<8;lane++){
				if(0!=(mask&(1<<lane))){
					// start Snap_valid
					*(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmTCSR2(lane) )= 0x80000000 ; //LNmTCSR2.RX_CDR_SNAP_STRT = 1
				}
			}

			for(lane=0;lane<8;lane++){
				if(0!=(mask&(1<<lane))){
				// wait for Snap_valid
				while ( *(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmTCSR2(lane) )!= 0xC0000000) {
						if(!running){exit(-1);}
					} ;   
				loop++;
				printf("\n time:0x%08lx, loop 0x%08x", read_core_cyclic_counter(),loop);
				printf("\n%s(%d)\t[0x%08x]:0x%08x","LNmTCSR3",lane, CCSR_SERDES1_OFF + LNmTCSR3(lane), *(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmTCSR3(lane)));
				printf("\n%s(%d)\t[0x%08x]:0x%08x","LNmTCSR4",lane, CCSR_SERDES1_OFF + LNmTCSR4(lane), *(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmTCSR4(lane)));
				printf("\n%s(%d)\t[0x%08x]:0x%08x","LNmRRSTCTL",lane, CCSR_SERDES1_OFF + LNmRRSTCTL(lane), *(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmRRSTCTL(lane)));
				printf("\n%s(%d)\t[0x%08x]:0x%08x","LNmRGCR1",lane, CCSR_SERDES1_OFF + LNmRGCR1(lane), *(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmRGCR1(lane)));
				printf("\n%s(%d)\t[0x%08x]:0x%08x","LNmRECR3",lane, CCSR_SERDES1_OFF + LNmRECR3(lane), *(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmRECR3(lane)));
				printf("\n%s(%d)\t[0x%08x]:0x%08x","LNmRECR4",lane, CCSR_SERDES1_OFF + LNmRECR4(lane), *(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmRECR4(lane)));
				// clear Snap_valid
				*(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmTCSR2(lane) )= 0x00000000 ; //LNmTCSR2.RX_CDR_SNAP_STRT = 0x0 
				}
			}
			sleep(1);
		}
	printf("\n");
	}

	if(dump) {
		
		/* dump only one lane , first tin the mask */
		for(lane=0;lane<8;lane++){
			if(0!=(mask&(1<<lane))) 
				break;
		}
		
		/* allocate buffer */ 
		uint32_t * ddr_addr_start=malloc(SNAP_LOOP*SNAP_LOOP_SIZE32*4*8);
		if(!ddr_addr_start){
			printf("ddr malloc fails");
			exit(-1);
		}
		
		uint32_t * ddr_addr=ddr_addr_start;
	    printf("\033[2J");
		/* Capture Various Registers */ 
		for (int snap_loop = 0;snap_loop<SNAP_LOOP ; snap_loop++) {
			*(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmTCSR2(lane) )= 0x80000000 ; //LNmTCSR2.RX_CDR_SNAP_STRT = 1
			while ( *(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmTCSR2(lane) )!= 0xC0000000) {
					if(!running){exit(-1);}
				} ;   // wait for Snap_valid
			loop++;
			*(ddr_addr++)=(uint32_t)read_core_cyclic_counter();
			*(ddr_addr++)=*(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmTCSR4(lane));
			*(ddr_addr++)=*(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmRRSTCTL(lane));
			*(ddr_addr++)=*(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmRGCR1(lane));
			*(ddr_addr++)=*(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmRECR3(lane));
			*(ddr_addr++)=*(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmRECR4(lane));
			*(volatile uint32_t *)((uint64_t)v_ccsr_serdes + LNmTCSR2(lane) )= 0x00000000 ; //LNmTCSR2.RX_CDR_SNAP_STRT = 0x0                 
		}

		/* export buffer to file */ 
		FILE *pFile = fopen(filename,"wb");
		if (!pFile)	{
			printf("Unable to open file!");
			exit(-1);
		}
		fwrite(ddr_addr_start,1,SNAP_LOOP*SNAP_LOOP_SIZE32*4,pFile);
		fclose (pFile);
		printf("\n capture in %s\n",filename);

		/* exit */ 
		free(ddr_addr_start);
	}
	
	return 0;
}



