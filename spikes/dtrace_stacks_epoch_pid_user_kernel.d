#!/usr/sbin/dtrace -s

#pragma D option quiet

BEGIN { iters = 0; }

profile-197Hz
/ pid && (pid > 1000) /
{
  @uks[pid,stack(),ustack()] = count();
}

tick-1sec
{
  iters++;
  printf("\n%u\n",walltimestamp/1000000000);
  printa("PID: %d\n%k %k %@12u\n",@uks);

  trunc(@uks);
}

tick-1sec
/ iters > 10 /
{
  exit(0);
}
