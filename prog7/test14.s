# Combined version of tests 11, 12, and 13.

.data

mainNumFormulas:
        .word 9
mainFormulas:
        .word mainFormula1
        .word mainFormula2
        .word mainFormula3
        .word mainFormula4
        .word mainFormula5
        .word mainFormula6
        .word mainFormula7
        .word mainFormula8
        .word mainFormula9

#                                 1         2        3         4         5
#                        1234567890123456789012346789012345678901234567890
mainFormula1:  .asciiz  "(7)"
mainFormula2:  .asciiz  "(formula + with - only + the + one * parens)"
mainFormula3:  .asciiz  "(a+(x) * (6 + 14) - q7)"
mainFormula4:  .asciiz  "(a+(x) * (6 + 14)   - q7"
mainFormula5:  .asciiz  "(a+(x) * (6 + 14   - q7)"
mainFormula6:  .asciiz  "( 19 +(1+(bat/cat) * (xray-sam)))"
mainFormula7:  .asciiz  "((((17 * (3 + a - b) / 7))+(6-abc)))"
mainFormula8:  .asciiz  "((((17 * (3 + a - b  / 7 )+(6-abc  )"
mainFormula9:  .asciiz  "((((17 * (3 + a - b) / 7))+(6-abc))"

mainNewline:
            .asciiz "\n"
mainString:
            .asciiz " -- main\n"
mainAfterString:
            .asciiz "main: after call to parens:\n"
mainNotBalancedStr:
            .asciiz "main: parens reports the formula is Not Balanced\n"
mainBalancedStr:
            .asciiz "main: parens reports the formula is Balanced\n"
mainHyphenString:
            .asciiz "+---------+---------+---------+---------"
.text
main:
         # Function prologue -- even main has one
         addiu $sp, $sp, -24      # allocate stack space -- default of 24 here
         sw    $fp, 0($sp)        # save caller's frame pointer
         sw    $ra, 4($sp)        # save return address
         addiu $fp, $sp, 24       # setup main's frame pointer

         # for ( i = 0; i < mainNumFormulas; i++ )
         #    find length of string
         #    cleanFormula
 
         addi  $s0, $zero, 0      # $s0 = i = 0
         la    $t0, mainNumFormulas
         lw    $s1, 0($t0)        # $s1 = number of strings
         la    $s2, mainFormulas  # $s2 = addr mainFormulas[0]
mainLoopBegin:
         slt   $t0, $s0, $s1      # $t0 = i < mainNumFormulas
         beq   $t0, $zero, mainLoopEnd
        
         # print the hyphens
         la    $a0, mainHyphenString
         addi  $v0, $zero, 4
         syscall
         syscall
         la    $a0, mainNewline
         addi  $v0, $zero, 4
         syscall
         
         # print the string
         lw    $a0, 0($s2)        # $s4 = addr of start of current string
         addi  $v0, $zero, 4
         syscall

         la    $a0, mainString
         addi  $v0, $zero, 4
         syscall
         # print a blank line
         la    $a0, mainNewline
         addi  $v0, $zero, 4
         syscall

         # Put something in $s3 through $s7 to test correctness of procedure
         # call conventions.  I am not using $s5-7 in this function
         # Values put in here should still be in these registers
         # after the function call.

         addi  $s3, $zero, -333
         addi  $s4, $zero, -444
         addi  $s5, $zero,  555
         addi  $s6, $zero, -666
         addi  $s7, $zero,  777

         lw    $a0, 0($s2)        # $a0 = addr of string start
         addi  $a1, $zero, 1      # $a1 = parens level, start at 1
         
         jal   parens
         
         addi  $t1, $v0, 0        # save return value in $t1

         # Check $s registers to see if the values changed during the
         # calls to ifAuthor and ifTitle.

         addi  $t0, $zero, -333
         bne   $t0, $s3, mainSerror
         addi  $t0, $zero, -444
         bne   $t0, $s4, mainSerror
         addi  $t0, $zero,  555
         bne   $t0, $s5, mainSerror
         addi  $t0, $zero, -666
         bne   $t0, $s6, mainSerror
         addi  $t0, $zero,  777
         bne   $t0, $s7, mainSerror
         j     mainSDone

.data
mainErrorStr:
         .asciiz "\nmain found problem with preserving $s register(s)\n\n"
.text
mainSerror:
         la    $a0, mainErrorStr
         addi  $v0, $zero, 4
         syscall

mainSDone:

         # print the string
         la    $a0, mainNewline   # print a blank line
         addi  $v0, $zero, 4
         syscall
         la    $a0, mainAfterString
         addi  $v0, $zero, 4
         syscall
         lw    $a0, 0($s2)        # $a0 = addr of formula start
         addi  $v0, $zero, 4
         syscall
         la    $a0, mainNewline
         addi  $v0, $zero, 4
         syscall
         
         # Did parens return a -1 (not balanced)? 
         addi  $t0, $zero, -1
         bne   $t1, $t0, mainPrintBalanced
         la    $a0, mainNotBalancedStr
         addi  $v0, $zero, 4
         syscall
         j     mainAfterBalance
mainPrintBalanced:
         la    $a0, mainBalancedStr
         addi  $v0, $zero, 4
         syscall

mainAfterBalance:
         # print a blank line
         la    $a0, mainNewline
         addi  $v0, $zero, 4
         syscall
        
         addi  $s0, $s0, 1        # i++
         addi  $s2, $s2, 4        # $s2 = addr of next string
         j     mainLoopBegin
 
mainLoopEnd:
 

mainDone:
         # Epilogue for main -- restore stack & frame pointers and return
         lw    $ra, 4($sp)        # get return address from stack
         lw    $fp, 0($sp)        # restore frame pointer of caller
         addiu $sp, $sp, 24       # restore stack pointer of caller
         jr    $ra                # return to caller

printFormula:
         # Function prologue
         addiu $sp, $sp, -24      # allocate stack space -- default of 24 here
         sw    $fp,  0($sp)       # save frame pointer of caller
         sw    $ra,  4($sp)       # save return address
         sw    $a0,  8($sp)       # save $a0 = addr of first char to print
         sw    $a1, 12($sp)       # save $a1 = how many chars to print
         addiu $fp, $sp, 20       # setup frame pointer of printFormula
 
         # for (i = $a0; i < $a0 + $a1; i++)
         #    print byte
        
         addi  $t0, $a0, 0        # i = $t0 = start of characters to print
         add   $t1, $a0, $a1      # $t1 = addr of last character to print
 
printFormulaLoopBegin:
         slt   $t2, $t0, $t1      # $t2 = i < $a0 + $a1
         beq   $t2, $zero, printFormulaLoopEnd
 
         # print the character
         lb    $a0, 0($t0)
         addi  $v0, $zero, 11
         syscall
 
         addi  $t0, $t0, 1        # i++
         j     printFormulaLoopBegin
 
printFormulaLoopEnd:

         # Put values in all the $a registers
         addi  $a0, $zero, -7777
         addi  $a1, $zero, -1111
         addi  $a2, $zero, -2222
         addi  $a3, $zero, -3333

         # Put values in all the $t registers
         addi  $t0, $zero, -7777
         addi  $t1, $zero, -1111
         addi  $t2, $zero, -2222
         addi  $t3, $zero,  3333
         addi  $t4, $zero, -4444
         addi  $t5, $zero, -5555
         addi  $t6, $zero,  6666
         addi  $t7, $zero, -7777
         addi  $t8, $zero, -8888
         addi  $t9, $zero,  9999
 
         # Epilogue for printFormula -- restore stack & frame pointers & return
         lw    $ra,  4($sp)       # get return address from stack
         lw    $fp,  0($sp)       # restore frame pointer of caller
         addiu $sp, $sp, 24       # restore stack pointer of caller
         jr    $ra                # return to caller

# Your code goes below this line
