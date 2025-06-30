# SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
#Copyright 2024 NXP


CFLAGS  +=  -g -O0 -Wall -Werror
LDFLAGS  += -lncurses

SRCS_TEST := serdes_bist.c utils.c
OBJS_TEST := $(SRCS_TEST:.c =.o)
BIN_TEST := serdes_bist

SRCS_TEST1 := serdes_snap.c utils.c
OBJS_TEST1 := $(SRCS_TEST:.c =.o)
BIN_TEST1 := serdes_snap

all: $(BIN_TEST) $(BIN_TEST1)

$(BIN_TEST): ${OBJS_TEST}
	${CC} ${CFLAGS} -o $(BIN_TEST) ${OBJS_TEST} $(INCLUDES) ${LDFLAGS} 

$(BIN_TEST1): ${OBJS_TEST1}
	${CC} ${CFLAGS} -o $(BIN_TEST1) ${OBJS_TEST1} $(INCLUDES) ${LDFLAGS} 

%.o: %.c
	${CC} -c ${CFLAGS} ${INCLUDES}  $< -o $@

clean:
	rm -rf *.o $(BIN_TEST) $(BIN_TEST1)

install:
	install -D $(BIN_TEST) ${BIN_INSTALL_DIR}/$(BIN_TEST)
	install -D $(BIN_TEST1) ${BIN_INSTALL_DIR}/$(BIN_TEST1)

