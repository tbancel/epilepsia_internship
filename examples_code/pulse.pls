            SET      0.10 1 0
            VAR    V1,num=0
            VAR    V2,prev=0
            VAR    V3,lev
            VAR    V4,del=-4

UNDER:      CHAN   num,1
            BGT    num,lev,pulse
            JUMP   under

OVER:       CHAN   num,1
            BLT    num,lev,under
            JUMP   over

PULSE:      DIGOUT [00000001]
            DELAY 8
            DIGOUT [00000000]
            JUMP   over