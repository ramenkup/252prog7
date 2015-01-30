#!/usr/bin/perl

use Cwd 'chdir';

$userfile = "prog7.s";
$spim = "/usr/local/bin/spim";
#$spim = "/Applications/spim";

if (not -e "$userfile") {
  die "Can't find $userfile!\n";
}

if (not -e "$spim") {
  die "Can't find $spim, note that this script should be run on lectura\n";
}

# Look for the required comment; exit with error if not found
@egrepOutput = `egrep -e "^( *)#( *)Your code goes below this line" $userfile > /dev/null`;
$exitcode = $? >> 8;
if ($exitcode != 0) {
  die "Can't find required comment: # Your code goes below this line\n";
}

while ($test = <test[0-9][0-9].s>) { # for each test
  # read in the test

  $testnum++;

  @testlines = `cat $test`;
    
  @lines = `cat $userfile`;
   
  $hashline = 0;
  foreach $linenum (0 .. $#lines) {
    if ($lines[$linenum] =~ /^(\s*)#(\s*)Your code goes below this line/i) {
	$hashline = $linenum;
      }
  }

  open (OUT, ">$test-user.s") or die "can't open $user/$test for writing\n";
  print OUT @testlines;
  foreach $linenum ($hashline .. $#lines) {
    print OUT $lines[$linenum];
  }
  close (OUT);

  # run the program
  
  @output = `$spim -file $test-user.s`;
  
  open (OUT, ">$test-user.out") or die "can't open $user/$test-user.out for writing\n";
  foreach $linenum (1 .. $#output) {
    print OUT $output[$linenum];
  }
  close (OUT);


  $testpassed = 0;
  # check the output
  #@diffoutput = `gdiff $test-user.out $test.out`;
  @diffoutput = `diff -C 1 $test-user.out $test.out`;
  $exitcode = $? >> 8;
  if ($exitcode != 0) {
    @userout = `cat $test-user.out`;
    @testout = `cat $test.out`;
    
    print "----------------------------------\n";
    print "test $testnum failed!\n";
#    print "---------Your output--------------\n";
#    print @userout;
#    print "--------Correct output------------\n";
#    print @testout;
#    print "----------------------------------\n";

    print "----------------------------------\n";
    print "diff result from running diff -C 1 $test-user.out $test.out\n";
    print @diffoutput;
    print "----------------------------------\n";
    
  }
  else {
    print "Test $testnum passed!\n";
  }
}
