#!/usr/bin/perl
# Modified from queue.pl
# Original Copyright 2012  Johns Hopkins University (Author: Daniel Povey).
# Apache 2.0.
use File::Basename;
use Cwd;

#host dispatch defaults
$domainfile = 'domain.info';
$memory = 1000;
$stagger = 5.0;
$priority = 10.0;
$local = 0;
$usetmp = 0;
$suppression = 1;
$usehost = 0;
$hosts = '';

#local dir things
$hostdcreatecmd = '/data/sls/babel/scripts/hostd_scratch/hostd_create_dir.pl';
$hostdcopycmd = '/data/sls/babel/scripts/hostd_scratch/hostd_copy_files_in_dir_to_dir.pl';
$hostddeletecmd = '/data/sls/babel/scripts/hostd_scratch/hostd_delete_dir.pl';
$hostlistfile = '/data/sls/babel/scripts/hostd_scratch/all.list';

if (@ARGV < 2) {
  print STDERR
   "Usage: hostd.pl [options to hostd] [JOB=1:n] log-file command-line arguments...\n" .
   "e.g.: hostd.pl foo.log echo baz\n" .
   " (which will echo \"baz\", with stdout and stderr directed to foo.log)\n" .
   "or: hostd.pl foo.log echo bar \| sed s/bar/baz/ \n" .
   " (which is an example of using a pipe; you can provide other escaped bash constructs)\n" .
   "or: hostd.pl -hostdmemory 1000 -hostdhosts \"sls-quad-5.csail.mit.edu+<m415s>\" JOB=1:10 foo.JOB.log echo JOB \n" .
   " (which illustrates the mechanism to submit parallel jobs; note, you can use \n" .
   "  another string other than JOB)\n" .
   "The script will first look at domain.info in the current directory for possible hostd settings\n" .
   "This can also be overwritten by specifying options\n" .
   "List of possible hostd options\n" .
   "-hostdpriority x [default $priority]\n" .
   "-hostdmemory x [default $memory]\n" .
   "-hostdstagger x [default $stagger]\n" .
   "-hostdhosts x [default <all>]\n" .
   "-hostdlocal 0/1 [default $local, setting to 1 will run localy]\n" .
   "-hostdsuppression 0/1/2 [default $suppression, setting to 1 will suppress non-servers dump, setting to 2 will suppress all dumps\n" .
   "-hostdusetmp 0/1 [default $usetmp, setting to 1 will dump logs and marked outputs to local /scratch\n" .
   "  to mark outputs DTMP should be used in front of directory\n" .
   "  for example DTMPexp/tri5/lat.JOB.gz will dump files to /tmp/hostd/USER/PLPROCESSID/exp/tri5/lat.JOB.gz\n" .
   "  before pooling it back to exp/tri5/lat.JOB.gz\n" .
   "  This only works for relative path\n" .
   "  Log files should not be marked\n";
  exit 1;
}

if (-e $domainfile) {
	print "$domainfile found. reading hostd settings\n";
	$a = `grep d:min_memory_mb $domainfile`;
	@stuffs = split(' ', $a);
	if(@stuffs == 3) {
		$memory = @stuffs[2];
	}
	$a = `grep d:stagger_time $domainfile`;
	@stuffs = split(' ', $a);
	if(@stuffs == 3) {
		$stagger = @stuffs[2];
	}
	$a = `grep d:sls_priority $domainfile`;
	@stuffs = split(' ', $a);
	if(@stuffs == 3) {
		$priority = @stuffs[2];
	}
	$a = `grep d:hostd_machine $domainfile`;
	@stuffs = split(' ', $a);
	if(@stuffs == 3) {
		$hosts = @stuffs[2];
		$usehost = 1;
	}
}

# hostd.pl has the same functionality as queue.pl, except that
# it runs the job in question on the host dispatch.

$qsub_opts = "";
$sync = 0;

for ($x = 1; $x <= 3; $x++) { # This for-loop is to 
  # allow the JOB=1:n option to be interleaved with the
  # options to qsub.
  while (@ARGV >= 2 && $ARGV[0] =~ m:^-:) {
    $switch = shift @ARGV;
    if ($switch eq "-hostdmemory") {
	$switch = shift @ARGV;
	$memory = $switch;
	print "memory is $memory\n";
    }
    if ($switch eq "-hostdstagger") {
	$switch = shift @ARGV;
	$stagger = $switch;
	print "stagger is $stagger\n";
    }
    if ($switch eq "-hostdpriority") {
	$switch = shift @ARGV;
	$priority = $switch;
	print "priority is $priority\n";
    }
    if ($switch eq "-hostdlocal") {
	$switch = shift @ARGV;
	$local = $switch;
	print "local is $local\n";
    }
    if ($switch eq "-hostdhosts") {
	$switch = shift @ARGV;
	$hosts = $switch;
	print "hosts is $hosts\n";
	$usehost = 1;
    }
    if ($switch eq "-hostdusetmp") {
	$switch = shift @ARGV;
	$usr = `id -u -n`;
	chomp($usr);
	$tmpdir = "/scratch/hostd/$usr/$$/";
	print "Using tmp directory $tmpdir\n";
	$usetmp = 1;
    }
    if ($switch eq "-hostdsuppression") {
	$switch = shift @ARGV;
	$suppression = $switch;
	print "Setting suppression level to $suppression\n";
    }
    if ($switch eq "-tc") {
        #some useless irrelavent flag
        $switch = shift @ARGV;
    }
    if ($switch =~ m/^--/) { # Config options
        # Convert CLI option to variable name
        # by removing '--' from the switch and replacing any 
        # '-' with a '_' 
        # SLS This is obviously unused for now!!
        $argument = shift @ARGV;
        $switch =~ s/^--//;
        $switch =~ s/-/_/g;         
        $cli_options{$switch} = $argument;
    }
  }
  if ($ARGV[0] =~ m/^([\w_][\w\d_]*)+=(\d+):(\d+)$/) {
    $jobname = $1;
    $jobstart = $2;
    $jobend = $3;
    shift;
    if ($jobstart > $jobend) {
      die "queue.pl: invalid job range $ARGV[0]";
    }
  } elsif ($ARGV[0] =~ m/^([\w_][\w\d_]*)+=(\d+)$/) { # e.g. JOB=1.
    $jobname = $1;
    $jobstart = $2;
    $jobend = $2;
    shift;
  } elsif ($ARGV[0] =~ m/.+\=.*\:.*$/) {
    print STDERR "Warning: suspicious first argument to hostd.pl: $ARGV[0]\n";
  }
}

$cwd = getcwd();
$logfile = shift @ARGV;

if (defined $jobname && $logfile !~ m/$jobname/
    && $jobend > $jobstart) {
  print STDERR "hostd.pl: you are trying to run a parallel job but "
    . "you are putting the output into just one log file ($logfile)\n";
  exit(1);
}

#####ADDED#######
#parse out a ctl file for outputing
$ctlfile = $logfile.'.ctl';

#
# Work out the command; quote escaping is done here.
# Note: the rules for escaping stuff are worked out pretty
# arbitrarily, based on what we want it to do.  Some things that
# we pass as arguments to queue.pl, such as "|", we want to be
# interpreted by bash, so we don't escape them.  Other things,
# such as archive specifiers like 'ark:gunzip -c foo.gz|', we want
# to be passed, in quotes, to the Kaldi program.  Our heuristic
# is that stuff with spaces in should be quoted.  This doesn't
# always work.
#
$cmd = "";

foreach $x (@ARGV) { 
  if ($usetmp == 1) {
    if ($x =~ m/DTMP/){
	($seg) = ($x =~ /DTMP(\S+)/);
	$thisoutdir = dirname($seg);
	push(@dirlist,$thisoutdir);
	$seg = "DTMP".$seg;
	$dir = dirname($seg);
	$dir =~ s/DTMP/$tmpdir/g;
	push(@tmpdirlist,$dir);
    }
  }
  if ($x =~ m/^\S+$/) { $cmd .= $x . " "; } # If string contains no spaces, take
                                            # as-is.
  elsif ($x =~ m:\":) { $cmd .= "'\''$x'\'' "; } # else if no dbl-quotes, use single
  else { $cmd .= "\"$x\" "; }  # else use double.
}

#
# Work out the location of the script file, and open it for writing.
#
$dir = dirname($logfile);
$base = basename($logfile);
$qdir = "$dir/q";
$qdir =~ s:/(log|LOG)/*q:/q:; # If qdir ends in .../log/q, make it just .../q.
$queue_logfile = "$qdir/$base";

if ($usetmp == 1) {
	$realcmd = $cmd;
	$cmd =~ s/DTMP/$tmpdir/g;
	$reallog = $logfile;
	$logfile = $tmpdir.'/'.$logfile;
	$tmplogdir = dirname($logfile);
	push(@tmpdirlist,$tmplogdir);
	push(@dirlist,$dir);
	system("$hostddeletecmd $tmpdir $hostlistfile");
}

if (!-d $dir) { system "mkdir -p $dir 2>/dev/null"; } # another job may be doing this...
if (!-d $dir) { die "Cannot make the directory $dir\n"; }
# make a directory called "q",
# where we will put the log created by qsub... normally this doesn't contain
# anything interesting, evertyhing goes to $logfile.
if (! -d "$qdir") { 
  system "mkdir -p $qdir 2>/dev/null";
  sleep(5); ## This is to fix an issue we encountered in denominator lattice creation,
  ## where if e.g. the exp/tri2b_denlats/log/15/q directory had just been
  ## created and the job immediately ran, it would die with an error because nfs
  ## had not yet synced.  I'm also decreasing the acdirmin and acdirmax in our
  ## NFS settings to something like 5 seconds.
} 

if (defined $jobname) { # It's an array job.
  $queue_array_opt = "-t $jobstart:$jobend"; 
  $logfile =~ s/$jobname/\$1/g; # This variable will get 
  # replaced by qsub, in each job, with the job-id.
  $cmd =~ s/$jobname/\$1/g; # same for the command...
  $queue_logfile =~ s/\.?$jobname//; # the log file in the q/ subdirectory
  # is for the queue to put its log, and this doesn't need the task array subscript
  # so we remove it.
}

# queue_scriptfile is as $queue_logfile [e.g. dir/q/foo.log] but
# with the suffix .sh.
$queue_scriptfile = $queue_logfile;
($queue_scriptfile =~ s/\.[a-zA-Z]{1,5}$/.sh/) || ($queue_scriptfile .= ".sh");
if ($queue_scriptfile !~ m:^/:) {
  $queue_scriptfile = $cwd . "/" . $queue_scriptfile; # just in case.
}

# We'll write to the standard input of "qsub" (the file-handle Q),
# the job that we want it to execute.
# Also keep our current PATH around, just in case there was something
# in it that we need (although we also source ./path.sh)

$syncfile = "$qdir/done.$$";

system("rm $queue_logfile $syncfile 2>/dev/null");
#
# Write to the script file, and then close it.
#
open(Q, ">$queue_scriptfile") || die "Failed to write to $queue_scriptfile";

print Q "#!/bin/bash\n";
print Q "cd $cwd\n";
#commment out next line if complains
print Q ". ./path.sh\n";
print Q "( echo '#' Running on \`hostname\`\n";
print Q "  echo '#' Started at \`date\`\n";
print Q "  echo -n '# '; cat <<EOF\n";
print Q "$cmd\n"; # this is a way of echoing the command into a comment in the log file,
print Q "EOF\n"; # without having to escape things like "|" and quote characters.
print Q ") >$logfile\n";
print Q " ( $cmd ) 2>>$logfile >>$logfile\n";
print Q "ret=\$?\n";
print Q "echo '#' Finished at \`date\` with status \$ret >>$logfile\n";
print Q "[ \$ret -eq 137 ] && exit 100;\n"; # If process was killed (e.g. oom) it will exit with status 137; 
  # let the script return with status 100 which will put it to E state; more easily rerunnable.
if (!defined $jobname) { # not an array job
  print Q "touch $syncfile\n"; # so we know it's done.
} else {
  print Q "touch $syncfile.\$SGE_TASK_ID\n"; # touch a bunch of sync-files.
}
print Q "exit \$[\$ret ? 1 : 0]\n"; # avoid status 100 which grid-engine
print Q "## submitted with:\n";       # treats specially.
print Q "# $qsub_cmd\n";
if (!close(Q)) { # close was not successful... || die "Could not close script file $shfile";
  die "Failed to close the script file (full disk?)";
}

`chmod 0777 $queue_scriptfile`;

#########
#write ctl file
open(CTL, ">$ctlfile") || die "Failed to write to $ctlfile";

for($i = $jobstart; $i < $jobend+1; $i++) {
	print CTL "$queue_scriptfile $i\n";
	print CTL "----------\n";
}
if (!close(CTL)) { # close was not successful... || die "Could not close script file $shfile";
  die "Failed to close the ctl file (full disk?)";
}
if($usehost == 1) {
	$hoststr = "-hosts $hosts";
} else {
	$hoststr = '';
}
if($local == 1) {
	$diststr = '';
} else {
	$diststr = '-distributed'
}

if ($usetmp == 1) {
	#create the dirs
	for $thisdir (@tmpdirlist) {
		system("$hostdcreatecmd $thisdir $hostlistfile");
	}
}

$ctlcmd = "ctl_exec -control $ctlfile -overwrite -rs_args \"-memory $memory -priority $priority -stagger $stagger $hoststr -overwrite\" $diststr";
print "$ctlcmd\n";
$suptext = '';
if($suppression == 1) {
	$suptext = ' | sed -e "/[0-9\.]\+\%, [0-9:]\+ $/d" -e "/[0-9\.]\+\%, [0-9]\+ [hrs]\+ [0-9:]\+ $/d" ';
	# suppress something like "0.00%, 32:34" and "98.44%, 1 hr 36:45"
} else {
	if($suppression == 2) {
		$suptext = ' | sed "/[0-9\.]\+\%/d" ';
	}
}
$ret = system("bash","-c","set -o pipefail; $ctlcmd".$suptext);
#exit(1);
#$ret = system ("qsub -S /bin/bash -v PATH -cwd -j y -o $queue_logfile $qsub_opts $queue_array_opt $queue_scriptfile >>$queue_logfile 2>&1");

if ($usetmp == 1) {
	for ($i = 0; $i < @tmpdirlist; $i++) {
		system("$hostdcopycmd $tmpdirlist[$i] $dirlist[$i] $hostlistfile");
	}	
	system("$hostddeletecmd $tmpdir $hostlistfile");
}
if ($ret != 0) {
  if ($sync && $ret == 256) { # this is the exit status when a job failed (bad exit status)
    if (defined $jobname) { $logfile =~ s/\$SGE_TASK_ID/*/g; }
    print STDERR "hostd.pl: job writing to $logfile failed\n";
  } else {
    print STDERR "hostd.pl: error submitting jobs to queue (return status was $ret)\n";
    print STDERR `tail $queue_logfile`;
  }
  exit(1);
}



if( 0) { # we can ignore syncing? what does syncing in sungrid do anyway?
	print "I should not see this line\n";
#if (! $sync) { # We're not submitting with -sync y, so we
  # need to wait for the jobs to finish.  We wait for the
  # sync-files we "touched" in the script to exist.
  @syncfiles = ();
  if (!defined $jobname) { # not an array job.
    push @syncfiles, $syncfile;
  } else {
    for ($jobid = $jobstart; $jobid <= $jobend; $jobid++) {
      push @syncfiles, "$syncfile.$jobid";
    }
  }
  # We will need the sge_job_id, to check that job still exists
  $sge_job_id=`grep "Your job" $queue_logfile | awk '{ print \$3 }' | sed 's|\\\..*||'`;
  chomp($sge_job_id);
  $check_sge_job_ctr=1;
  #
  $wait = 0.1;
  foreach $f (@syncfiles) {
    # wait for them to finish one by one.
    while (! -f $f) {
      sleep($wait);
      $wait *= 1.2;
      if ($wait > 3.0) {
        $wait = 3.0; # never wait more than 3 seconds.
        if (rand() > 0.5) {
          system("touch $qdir/.kick");
        } else {
          system("rm $qdir/.kick 2>/dev/null");
        }
        # This seems to kick NFS in the teeth to cause it to refresh the
        # directory.  I've seen cases where it would indefinitely fail to get
        # updated, even though the file exists on the server.
        system("ls $qdir >/dev/null");
      }

      # Check that the job exists in SGE. Job can be killed if duration 
      # exceeds some hard limit, or in case of a machine shutdown. 
      if(($check_sge_job_ctr++ % 10) == 0) { # Don't run qstat too often, avoid stress on SGE.
        if ( -f $f ) { next; }; #syncfile appeared, ok
        $ret = system("qstat -j $sge_job_id >/dev/null 2>/dev/null");
        if($ret != 0) {
          # Don't consider immediately missing job as error, first wait some  
          # time to make sure it is not just delayed creation of the syncfile.
          sleep(3);
          if ( -f $f ) { next; }; #syncfile appeared, ok
          sleep(7);
          if ( -f $f ) { next; }; #syncfile appeared, ok
          sleep(20);
          if ( -f $f ) { next; }; #syncfile appeared, ok
          #Otherwise it is an error
          if (defined $jobname) { $logfile =~ s/\$SGE_TASK_ID/*/g; }
          print STDERR "queue.pl: Error, unfinished job no longer exists, log is in $logfile\n";
          print STDERR "          Possible reasons: a) Exceeded time limit? -> Use more jobs! b) Shutdown/Frozen machine? -> Run again!\n";
          exit(1);
        }
      }
    }
  }
  $all_syncfiles = join(" ", @syncfiles);
  system("rm $all_syncfiles 2>/dev/null");
}

# OK, at this point we are synced; we know the job is done.
# But we don't know about its exit status.  We'll look at $logfile for this.
# First work out an array @logfiles of file-locations we need to
# read (just one, unless it's an array job).

if ($usetmp == 1) {
	$logfile = $reallog;
        $logfile =~ s/$jobname/\$1/g;
}

$reran=0;
while($reran < 2) {
  @logfiles = ();
  if (!defined $jobname) { # not an array job.
    push @logfiles, $logfile;
  } else {
    for ($jobid = $jobstart; $jobid <= $jobend; $jobid++) {
      $l = $logfile; 
      $l =~ s/\$1/$jobid/g;
      push @logfiles, $l;
    }
  }

  $num_failed = 0;
  @failed = ();
  foreach $l (@logfiles) {
    $line = `tail -10 $l 2>/dev/null`; # Note: although this line should be the last
    # line of the file, I've seen cases where it was not quite the last line because
    # of delayed output by the process that was running, or processes it had called.
    # so tail -10 gives it a little leeway.
    if ($line =~ m/with status (\d+)/) {
      $status = $1;
    } else {
      if (! -f $l) {
        print STDERR "Log-file $l does not exist.\n";
        $status=100; 
      } else {
        print STDERR "The last line of log-file $l does not seem to indicate the "
          . "return status as expected\n";
        $status=99;
      }
      # Something went wrong with the queue, or the
      # machine it was running on, probably.
    }
    # OK, now we have $status, which is the return-status of
    # the command in the job.
    if ($status != 0) { $num_failed++; push @failed, $l;}
  }

  if ($num_failed == 0) { exit(0); }
  else { # we failed.
    if (@logfiles == 1) {
      if (defined $jobname) { $logfile =~ s/\$SGE_TASK_ID/$jobstart/g; }
      print STDERR "hostd.pl: job failed with status $status, log is in $logfile\n";
      if ($logfile =~ m/JOB/) {
        print STDERR "hostd.pl: probably you forgot to put JOB=1:\$nj in your script.\n";
      }
      exit(1);
    } else {
      if (defined $jobname) { $logfile =~ s/\$SGE_TASK_ID/*/g; }
      $numjobs = 1 + $jobend - $jobstart;
      print STDERR "hostd.pl: $num_failed / $numjobs failed, log is in $logfile\n";
      if($reran < 1) {
        print "Restarting failed jobs.\n";
        $newctlfile = $ctlfile.'.rerun.ctl';
        print "Creating new ctl $newctlfile\n";
        open(CTL, ">$newctlfile") || die "Failed to write to $newctlfile";
        foreach $l (@failed) {
          @filenamesplit = split('\.',$l);
          print CTL "$queue_scriptfile $filenamesplit[-2]\n";
          print CTL "----------\n";      
        }
        if (!close(CTL)) { # close was not successful... || die "Could not close script file $shfile";
          die "Failed to close the ctl file (full disk?)";
        }
        if ($usetmp == 1) {
          #create the dirs
          for $thisdir (@tmpdirlist) {
            system("$hostdcreatecmd $thisdir $hostlistfile");
          }
        }
        $ctlcmd = "ctl_exec -control $newctlfile -overwrite -rs_args \"-memory $memory -priority $priority -stagger $stagger $hoststr -overwrite\" $diststr";
        print "$ctlcmd\n";
        $ret = system("bash","-c","set -o pipefail; $ctlcmd".$suptext);
        $reran=$reran+1;
        if ($usetmp == 1) {
          for ($i = 0; $i < @tmpdirlist; $i++) {
            system("$hostdcopycmd $tmpdirlist[$i] $dirlist[$i] $hostlistfile");
          } 
          system("$hostddeletecmd $tmpdir $hostlistfile");
        }
      } else {
        exit(1);
      }
    }
  }
}
