#!/bin/bash
#
###########################################################
# Called on a cron to run EVS jobs                        #
###########################################################

set -x

now=`date -u +%Y%m%d%H`
vhr=`echo $now | cut -c 9-10`

LOGDIR=${LOGDIR:-"/lfs/h2/emc/ptmp/${USER}/output/retros/${retro_name}"}
mkdir -p $LOGDIR
cd $LOGDIR

module reset

qsub ${SCRIPTevs}/plots/cam/jevs_cam_firewxnest_grid2obs_plots.sh

exit

