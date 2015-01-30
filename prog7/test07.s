# Two strings with many levels of parentheses.  Balanced.

.data

mainNumFormulas:
        .word 2
mainFormulas:
        .word mainFormula1
        .word mainFormula2

mainFormula1:  .asciiz "(a((((b(c((d((e)f((g+h((i)((j+k((l(m)((n))o(p+q(o))r)(s+t(((u(v+w))x))((y((z))a))))b))))c((((d)e))f))(g((h)i)(j(k((l+m)n)o))(p(q))r)s+t-u))v))(w)(x)(y)))(z)((a)b))c(d)f))"
mainFormula2:  .asciiz "(a((((b(c((d((e)f((g+h((i)((j+k((l(m)((n))o(p+q(o))r)(s+t(((u(v+w))x))((y((z))a))))b))))c((((d)e))f))(g((h(a((((b(c((d((e)f((g+h((i)((j+k((l(m)((n))o(p+q(o))r)(s+t(((u(v+w))x))((y((z))a))))b))))c((((d)e))f))(g((h)i)(j(k((l+m)n)o))(p(q))r)s+t-u))v))(w)(x)(y)))(z)((a)b))c(d)f))))i)(j(k((l+m)n)o))(p(q))r)s+t-u))v))(w)(x)(y)))(z)((a)b))c(d)f)"


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

         lw    $a0, 0($s2)        # $a0 = addr of string start
         addi  $a1, $zero, 1      # $a1 = parens level, start at 1
         
         jal   parens
         
         addi  $t1, $v0, 0        # save return value in $t1

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
 
         # Epilogue for printFormula -- restore stack & frame pointers & return
         lw    $a1, 12($sp)       # restore $a1
         lw    $a0,  8($sp)       # restore $a0
         lw    $ra,  4($sp)       # get return address from stack
         lw    $fp,  0($sp)       # restore frame pointer of caller
         addiu $sp, $sp, 24       # restore stack pointer of caller
         jr    $ra                # return to caller

# Your code goes below this line
