;Author information
;  Author name: Andre White
;  Author email: Awhiteis21@fullerton.edu
;Course information
;  Course number: CPSC240
;  Assignment number: 02
;  Due date: 2014-Sep-10
;  Date of last modification: 2014-Sep-10
;Project information
;  Project title: Electric Circuits in Parallel
;  Purpose: Use vector processing to compute the correct circuit values
;  Status: In continuous maintenance
;  Project files: hw.asm current.c
;  Modules (subprograms): none
;Translator information
;  Linux: nasm -f elf64 -l hw.lis -o hw.o hw.asm
;References and credits
;  Professor Floyd Holliday
;Format information
;  Page width: 172 columns
;  Begin comments: 61
;  Optimal print specification: Landscape orientation, 7 points, monospace, 8½x11 paper


%include "debug.inc"
        segment .data
xsavenotsupported.notsupportedmessage db "The xsave instruction is not suported in this microprocessor.", 10
                                      db "However, processing will continue without backing up state component data", 10, 0

;===== Declare formats for output =========================================================================================================================================



xsavenotsupported.stringformat db "%s", 0
rtval		dd	0
fmt1 		db 	"%lf",0
fmt  		db  	"%lf %lf %lf %lf" ,0
fmt2 		db  	"%s", 0
welcome 	db 	"Welcome to Electric Circuit Processing by Andre White",0x0a,0
welcome1 	db 	"This Program will analyze direct current circuits configured in parallel",0x0a,0
request2 	db 	"Enter the Four Power Values: ", 0
request1 	db 	"Enter the Total Voltage: ", 0
prompt  	db 	"Total Circuit Voltage is: %1.18lf ",0x0a,0
prompt2 	db 	"Device number:          1                      2                   3                  4",0x0a,0
prompt3 	db 	"Power(watts): %1.18lf %1.18lf %1.18lf %1.18lf",0x0a,0
prompt4 	db 	"Current(amps): %1.18lf %1.18lf %1.18lf %1.18lf",0x0a,0
prompt5 	db 	"Total current in the circuit is:  %1.18lf amps",0x0a,0
prompt6 	db 	"Total Power in the circuit is: %1.18lf watts",0x0a,0
outpt 		db 	"%1.18lf %1.18lf %1.18lf %1.18lf",0x0a
outpt1 		db	 0x0a,"Thank you. The computations have completed with the following results",0x0a,0x0a,0
outpt2 		db 	"The analyzer program will now return the total power to the driver", 0x0a,0x0a,0
  
	segment .bss                                                ;Uninitialized data are declared in this segment

align 64                                                    ;Ask that the next data declaration start on a 64-byte boundary.
backuparea resb 832                                         ;Create an array for backup storage having 832 bytes.

	segment .text
        global current
        extern scanf
        extern printf
	

current:
	align 16                                                    ;Start the next instruction on a 16-byte boundary

;=========== Back up all the GPRs whether used in this program or not =====================================================================================================

push       rbp                                              ;Save a copy of the stack base pointer
mov        rbp, rsp                                         ;We do this in order to be 100% compatible with C and C++.
push       rbx                                              ;Back up rbx
push       rcx                                              ;Back up rcx
push       rdx                                              ;Back up rdx
push       rsi                                              ;Back up rsi
push       rdi                                              ;Back up rdi
push       r8                                               ;Back up r8
push       r9                                               ;Back up r9
push       r10                                              ;Back up r10
push       r11                                              ;Back up r11
push       r12                                              ;Back up r12
push       r13                                              ;Back up r13
push       r14                                              ;Back up r14
push       r15                                              ;Back up r15
pushf                                                       ;Back up rflags


;==========================================================================================================================================================================
;===== Begin State Component Backup =======================================================================================================================================
;==========================================================================================================================================================================

;=========== Before proceeding verify that this computer supports xsave and xrstor ========================================================================================
;Bit #26 of rcx, written rcx[26], must be 1; otherwise xsave and xrstor are not supported by this computer.
;Preconditions: rax holds 1.
mov        rax, 1

;Execute the cpuid instruction
cpuid

;Postconditions: If rcx[26]==1 then xsave is supported.  If rcx[26]==0 then xsave is not supported.

;=========== Extract bit #26 and test it ==================================================================================================================================

and        rcx, 0x0000000004000000                          ;The mask 0x0000000004000000 has a 1 in position #26.  Now rcx is either all zeros or
                                                            ;has a single 1 in position #26 and zeros everywhere else.
cmp        rcx, 0                                           ;Is (rcx == 0)?
je         xsavenotsupported                                ;Skip the section that backs up state component data.

;========== Call the function to obtain the bitmap of state components ====================================================================================================

;Preconditions
mov        rax, 0x000000000000000d                          ;Place 13 in rax.  This number is provided in the Intel manual
mov        rcx, 0                                           ;0 is parameter for subfunction 0

;Call the function
cpuid                                                       ;cpuid is an essential function that returns information about the cpu

;Postconditions (There are 2 of these):

;1.  edx:eax is a bit map of state components managed by xsave.  At the time this program was written (2014 June) there were exactly 3 state components.  Therefore, bits
;    numbered 2, 1, and 0 are important for current cpu technology.
;2.  ecx holds the number of bytes required to store all the data of enabled state components. [Post condition 2 is not used in this program.]
;This program assumes that under current technology (year 2014) there are at most three state components having a maximum combined data storage requirement of 832 bytes.
;Therefore, the value in ecx will be less than or equal to 832.

;Precaution: As an insurance against a future time when there will be more than 3 state components in a processor of the X86 family the state component bitmap is masked to
;allow only 3 state components maximum.

mov        r15, 7                                           ;7 equals three 1 bits.
and        rax, r15                                         ;Bits 63-3 become zeros.
mov        r15, 0                                           ;0 equals 64 binary zeros.
and        rdx, r15                                         ;Zero out rdx.

;========== Save all the data of all three components except GPRs =========================================================================================================

;The instruction xsave will save those state components with on bits in the bitmap.  At this point edx:eax continues to hold the state component bitmap.

;Precondition: edx:eax holds the state component bit map.  This condition has been met by the two pops preceding this statement.
xsave      [backuparea]                                     ;All the data of state components managed by xsave have been written to backuparea.

push qword -1                                               ;Set a flag (-1 = true) to indicate that state component data were backed up.
jmp        startapplication

;========== Show message xsave is not supported on this platform ==========================================================================================================
xsavenotsupported:

mov        rax, 0
mov        rdi, .stringformat
mov        rsi, .notsupportedmessage                        ;"The xsave instruction is not suported in this microprocessor.
call       printf

push qword 0                                                ;Set a flag (0 = false) to indicate that state component data were not backed up.

;==========================================================================================================================================================================
;===== End of State Component Backup ======================================================================================================================================
;==========================================================================================================================================================================
startapplication: ;===== Begin the application here:
       
        mov rdi, fmt2
        mov rsi, welcome1
        xor eax, eax
        call printf

        ;Request Total Voltage


        mov rdi,fmt2
        mov rsi, request1
        xor eax, eax
        call printf

        ;Get input of Voltage
        mov rdi, fmt1
        xor eax, eax
        push dword 0

        mov rsi,rsp
        call scanf

        ; Make input all of ymm register
        vbroadcastsd ymm15,[rsp]
        vbroadcastsd ymm10,[rsp-128]

        ;Request Device Power
        mov rdi,fmt2
        mov rsi, request2
        xor eax, eax
        call printf

        ;Grab input of all the numbers at once
        mov rdi, fmt
        xor eax, eax
        push dword 0

        mov rsi, rsp
        push dword 0

        mov rdx, rsp
        push dword 0

        mov rcx, rsp
        push dword 0

        mov  r8, rsp
        call scanf

        ;Put all input in the ymm register
        vmovupd ymm14,[rsp]

        ;Thank you
        mov rdi,fmt2
        mov rsi, outpt1
        xor eax, eax
        call printf



        ;extract the upper half ymm registers and put them in xmm
        vextractf128 xmm13, ymm14,1
        vextractf128 xmm12, ymm15,1
        ;showxmmregisters 13

        ;movapd xmm0,xmm10

        ;xmm13&xmm14=input2/input1
        movapd xmm10,xmm12
        movapd xmm0,xmm10
        mov rdi, prompt
        mov rax, 1
        call printf

        mov rdi, prompt2
        xor eax,eax
        call printf

        movapd xmm3,xmm14
        movapd xmm1,xmm13
        movhlps xmm2, xmm14
        movhlps xmm0, xmm13



        ;output numbers
        mov rdi, prompt3
        mov rax, 4
        call printf


        movapd xmm12,xmm15
        movapd xmm10,xmm15
        divpd xmm14,xmm15
        divpd xmm13,xmm12





        ;move current for correct output
        movapd xmm3,xmm14
        movapd xmm1,xmm13
        movhlps xmm2, xmm14
        movhlps xmm0, xmm13




        ;output numbers
        mov rdi, prompt4
        mov rax, 4
        call printf


        ;get total current
        addpd xmm14,xmm13
        movhlps xmm12,xmm14
        addpd xmm12,xmm14
        movapd xmm0,xmm12

        mulpd xmm15,xmm12


        mov rdi, prompt5
        mov rax, 1
        call printf

	movupd [rtval],xmm15	
	
        movupd xmm0,[rtval]
        mov rdi, prompt6
        mov rax, 1
        call printf

        mov rdi, outpt2
        xor eax, eax
        call printf

	
       
	
        pop rax
        pop rax
        pop rax
        pop rax
        pop rax
	
	

;===== Begin State Component Restore ======================================================================================================================================
;==========================================================================================================================================================================

;===== Check the flag to determine if state components were really backed up ==============================================================================================

pop        rbx                                              ;Obtain a copy of the flag that indicates state component backup or not.

cmp        rbx, 0                                           ;If there was no backup of state components then jump past the restore section.
je         setreturnvalue                                   ;Go to set up the return value.

;Continue with restoration of state components;

;Precondition: edx:eax must hold the state component bitmap.  Therefore, go get a new copy of that bitmap.

;Preconditions for obtaining the bitmap from the cpuid instruction
mov        rax, 0x000000000000000d                          ;Place 13 in rax.  This number is provided in the Intel manual
mov        rcx, 0                                           ;0 is parameter for subfunction 0

;Call the function
cpuid                                                       ;cpuid is an essential function that returns information about the cpu

;Postcondition: The bitmap in now in edx:eax

;Future insurance: Make sure the bitmap is limited to a maximum of 3 state components.
mov        r15, 7
and        rax, r15
mov        r15, 0
and        rdx, r15

xrstor     [backuparea]

;==========================================================================================================================================================================
;===== End State Component Restore ========================================================================================================================================
;==========================================================================================================================================================================


setreturnvalue: ;=========== Set the value to be returned to the caller ===================================================================================================

       movupd xmm0,[rtval]     	                                         ;r14 continues to hold the first computed floating point value.
                                    ;That first computed floating point value is copied to xmm0[63-0]
                                              ;Reverse the push of two lines earlier.

;=========== Restore GPR values and return to the caller ==================================================================================================================

popf                                                        ;Restore rflags
pop        r15                                              ;Restore r15
pop        r14                                              ;Restore r14
pop        r13                                              ;Restore r13
pop        r12                                              ;Restore r12
pop        r11                                              ;Restore r11
pop        r10                                              ;Restore r10
pop        r9                                               ;Restore r9
pop        r8                                               ;Restore r8
pop        rdi                                              ;Restore rdi
pop        rsi                                              ;Restore rsi
pop        rdx                                              ;Restore rdx
pop        rcx                                              ;Restore rcx
pop        rbx                                              ;Restore rbx
pop        rbp                                              ;Restore rbp


        ret
