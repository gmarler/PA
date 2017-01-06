#!/usr/sbin/dtrace -s

#pragma D option quiet

/*
 * A DTrace that generates the various forms of stack trace we need to be able
 * to parse into a form that can be flame graphed
 */

profile-197Hz
/ arg0 && curthread->t_pri != -1/
{
  @ks[stack()]                               = count();
  @ks_w_ts[walltimestamp,stack()]            = count();
  @ks_w_epoch[walltimestamp/1000000,stack()] = count();
}

profile-199Hz
/ pid && (pid > 1000)/
{
  @us[ustack()]                                        = count();
  @uks[stack(),ustack()]                               = count();
  @us_w_ts[walltimestamp,ustack()]                     = count();
  @uks_w_ts[walltimestamp,stack(),ustack()]            = count();
  @us_w_epoch[walltimestamp/1000000,ustack()]          = count();
  @uks_w_epoch[walltimestamp/1000000,ustack(),stack()] = count();
}

tick-10sec
{
  trunc(@ks,5);
  trunc(@ks_w_ts,5);
  trunc(@ks_w_epoch,5);

  trunc(@us, 5);
  trunc(@uks, 5);
  trunc(@us_w_ts, 5);
  trunc(@uks_w_ts, 5);
  trunc(@us_w_epoch, 5);
  trunc(@uks_w_epoch, 5);

  printa(@ks);
  printa("%Y %k %@12u\n\n",@ks_w_ts);
  printa("%d %k %@12u\n\n",@ks_w_epoch);

  printa(@us);
  printa(@uks);
  printa("%Y %k %@12u\n\n",@us_w_ts);
  printa("%Y %k %k %@12u\n\n",@uks_w_ts);
  printa("%d %k %@12u\n\n",@us_w_epoch);
  printa("%d %k %k %@12u\n\n",@uks_w_epoch);

  trunc(@ks);
  trunc(@ks_w_ts);
  trunc(@ks_w_epoch);

  trunc(@us);
  trunc(@uks);
  trunc(@us_w_ts);
  trunc(@uks_w_ts);
  trunc(@us_w_epoch);
  trunc(@uks_w_epoch);

  exit(0);
}
