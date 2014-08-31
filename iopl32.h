#if !defined __IOPL32_H
#define __IOPL32_H

#if defined __WATCOMC__ || defined __WATCOMCPP__

int getCurrentRing(void);
int enterIOPL32(void);
int leaveIOPL32(void);

#pragma aux getCurrentRing "_getCurrentRing" parm caller [] value [eax]
#pragma aux enterIOPL32    "_enterIOPL32"    parm caller [] value [eax]
#pragma aux leaveIOPL32    "_leaveIOPL32"    parm caller [] value [eax]

#else

#if defined __cplusplus
extern "C" {
#endif

int __cdecl getCurrentRing(void);
int __cdecl enterIOPL32(void);
int __cdecl leaveIOPL32(void);

#if defined __cplusplus
}
#endif  /* defined __cplusplus */

#endif  /* defined __WATCOMC__ || defined __WATCOMCPP__ */

#endif  /* __IOPL32_H */
