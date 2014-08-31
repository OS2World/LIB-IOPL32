#if defined __IBMC__ || defined __IBMCPP__
#include <builtin.h>
#endif

#if defined __WATCOMC__ || defined __WATCOMCPP__
#include <conio.h>
#define __inpb  inp
#define __outpb outp
#endif

#include <stdio.h>
#include "iopl32.h"

main()
{
    int ringArray[3];

    ringArray[0] = getCurrentRing();

    enterIOPL32();

    ringArray[1] = getCurrentRing();

    unsigned char beepPort = __inpb(0x61);

    for (int i = 0; i < 5; i++)
    {
        for (int j = 0; j < 1000; j++)
        {
            __outpb(0x61, beepPort | 3);
            for (int k = 0; k < 3000; k++)
                ;
            __outpb(0x61, beepPort &= 0xFC);
            for (k = 0; k < 3000; k++)
                ;
        }
    }
    __outpb(0x61, beepPort);

    leaveIOPL32();

    ringArray[2] = getCurrentRing();

    printf("Program ran at rings:\n");
    for (i = 0; i < sizeof(ringArray) / sizeof(ringArray[0]); i++)
        printf("    ring %d\n", ringArray[i]);

    return 0;
}
