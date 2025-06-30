#include <stdio.h>
#include <ncurses.h>

#define MAX_PARAM 5

int main() {
        int i,c;
        int param;
        initscr();
        keypad(stdscr, TRUE);
        noecho();

        printw("hello\n");
        refresh();
        timeout(1000);

        while(1){
                move(5,0);
                refresh();
                for(i=0;i<=MAX_PARAM;i++){
                        printw("\n(%s),%d",(i==param?"*":" "),i);
                }
                c = getch();
                if(c==ERR) continue;
                switch(c) {
                        case KEY_DOWN:
                                if(param!=MAX_PARAM) param++;
                        break;
                        case KEY_UP:
                                if(param!=0) param--;
                        break;
                        default:
                        break;
                }
        }

        getch();
        endwin();
        return 0;
}
