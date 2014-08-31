all: iopl32.dll iopl32.lib

iopl32.dll : iopl32.obj iopl32.def
	link386 /noi iopl32.obj,iopl32.dll,nul,,iopl32.def
	lxnrem iopl32.dll

iopl32.lib : iopl32.def
	implib /noi iopl32.lib iopl32.def

iopl32.obj : iopl32.asm
	alp iopl32.asm -Fo:iopl32.obj

iopl32.def : iopl32.mak
	echo <<$@
LIBRARY IOPL32 INITGLOBAL TERMGLOBAL
DESCRIPTION "IOPL32 helper library"

DATA NONE

SEGMENTS
	IOPL16		LOADONCALL EXECUTEONLY IOPL
	CODE32		LOADONCALL EXECUTEREAD ALIAS
	SINGLEBSS32	CLASS 'SINGLEBSS' PRELOAD SHARED READWRITE
	MULTIPLEBSS32	CLASS 'MULTIPLEBSS' LOADONCALL NONSHARED READWRITE

EXPORTS
	_getCurrentRing	@1	NONAME
	_enterIOPL32	@2	NONAME
	_leaveIOPL32	@3	NONAME
	checkIOPL32	@15
	enterIOPL	@16
	leaveIOPL	@17
<<keep
