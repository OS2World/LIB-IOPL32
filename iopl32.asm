		.386p

PUBLIC	checkIOPL32
PUBLIC	enterIOPL
PUBLIC	leaveIOPL

PUBLIC	_getCurrentRing
PUBLIC	_enterIOPL32
PUBLIC	_leaveIOPL32

SINGLEBSS32	SEGMENT USE32 DWORD PUBLIC 'SINGLEBSS'
SINGLEBSS32	ENDS
MULTIPLEBSS32	SEGMENT USE32 DWORD PUBLIC 'MULTIPLEBSS'
MULTIPLEBSS32	ENDS
IOPL16		SEGMENT USE16 WORD PUBLIC 'CODE'
IOPL16		ENDS
CODE32		SEGMENT USE32 DWORD PUBLIC 'CODE'
CODE32		ENDS

FLAT		GROUP CODE32

SINGLEBSS32	SEGMENT

selStackIOPL32	DW ?

ofsCodeIOPL32	DD ?
selCodeIOPL32	DW ?

SINGLEBSS32	ENDS

MULTIPLEBSS32	SEGMENT

keepSPIOPL16	DW ?
keepSSIOPL16	DW ?

MULTIPLEBSS32	ENDS

IOPL16		SEGMENT
		ASSUME	cs:IOPL16,ds:FLAT

checkIOPL32	PROC	FAR
	push	bp
	mov	bp,sp
	sub	sp,16+8

	sub	eax,eax
	mov	[selStackIOPL32],ax

	mov	ax,[selCodeIOPL32]
	cmp	sp,0
	verr	ax
	jnz	SHORT checkIOPL32Done

	mov	ax,ds
	lsl	ebx,eax
	mov	[bp-16-8],ebx
	lar	bx,ax

	sgdt	[bp-16]
	mov	cx,[bp-16]
	inc	cx
	shr	cx,3
	dec	cx
	mov	ax,2
getStackSel:
	add	ax,8
	lar	dx,ax
	xor	dx,bx
	cmp	dx,0f300h xor 0d300h
	jne	SHORT nextSel

	lsl	edx,eax
	cmp	edx,[bp-16-8]
nextSel:
	loopne	getStackSel
	jnz	SHORT checkIOPL32Done

	mov	[selStackIOPL32],ax
checkIOPL32Done:
	mov	sp,bp
	pop	bp
	ret
checkIOPL32	ENDP

enterIOPL	PROC	FAR
	mov	[keepSPIOPL16],sp
	mov	[keepSSIOPL16],ss
	jmp	FWORD PTR [ofsCodeIOPL32]
enterIOPL	ENDP

leaveIOPL	PROC	FAR
	ret
leaveIOPL	ENDP

IOPL16		ENDS

CODE32		SEGMENT
		ASSUME	cs:FLAT,ds:FLAT

_getCurrentRing	PROC	NEAR
	mov	eax,cs
	and	eax,3
	ret
_getCurrentRing	ENDP

_enterIOPL32	PROC	NEAR
	mov	eax,cs
	and	al,3
	cmp	al,2
	mov	eax,0
	je	SHORT _enterIOPL32Done

	dec	eax
	cmp	[selStackIOPL32],0
	je	SHORT _enterIOPL32Done

	push	ebp
	mov	ebp,esp
	movzx	eax,[selStackIOPL32]
	push	eax
	push	ebp

	mov	eax,esp
	mov	edx,eax
	and	eax,0ffffh
	shr	edx,13
	or	edx,7
	push	edx
	push	eax
	lss	esp,[esp]

	DB	0eah
	DF	CODE32:_enterIOPL32Enter16

_enterIOPL32Enter16	LABEL	FAR
	DB	9ah
	DD	IOPL16:enterIOPL

	DB	66h
	DB	0eah
	DF	FLAT:jumpOnLeaveIOPL32

jumpOnLeaveIOPL32	LABEL	FAR
	jmp	SHORT _leaveIOPL32Enter32

_enterIOPL32Enter32	LABEL	FAR
	lss	esp,ds:[ebp-8]
	pop	ebp

	sub	eax,eax
_enterIOPL32Done:
	ret
_enterIOPL32	ENDP

_leaveIOPL32	PROC	NEAR
	mov	eax,cs
	and	al,3
	cmp	al,3
	mov	ax,0
	je	SHORT _leaveIOPL32Done

	push	ebp
	mov	ebp,esp
	push	ds
	push	ebp

	mov	ss,[keepSSIOPL16]
	mov	sp,[keepSPIOPL16]

	DB	66h
	DB	0eah
	DD	IOPL16:leaveIOPL
_leaveIOPL32Enter32:
	lss	esp,ds:[ebp-8]
	pop	ebp

	sub	eax,eax
_leaveIOPL32Done:
	ret
_leaveIOPL32	ENDP

init		PROC	NEAR
	cmp	DWORD PTR [esp+8],0
	jne	SHORT initDone

	mov	eax,cs
	and	al,0feh
	mov	[selCodeIOPL32],ax
	mov	[ofsCodeIOPL32],OFFSET FLAT:_enterIOPL32Enter32

	push	ebp
	mov	ebp,esp
	push	ss
	push	ebp

	mov	eax,esp
	mov	edx,eax
	and	eax,0ffffh
	shr	edx,13
	or	edx,7
	push	edx
	push	eax
	lss	esp,[esp]

	DB	0eah
	DF	CODE32:initEnter16

initEnter16	LABEL	FAR
	DB	9ah
	DD	IOPL16:checkIOPL32

	DB	66h
	DB	0eah
	DF	FLAT:initEnter32

initEnter32	LABEL	FAR
	lss	esp,ds:[ebp-8]
	pop	ebp
initDone:
	mov	eax,1
	ret
init		ENDP

CODE32		ENDS

		END	init
