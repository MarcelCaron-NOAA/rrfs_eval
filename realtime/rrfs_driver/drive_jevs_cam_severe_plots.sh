#!/bin/bash
# Author: M.G. Caron & L.C. Dawson
#
###########################################################
# Called on a cron to run EVS jobs                        #
###########################################################

now=`date -u +%Y%m%d%H`
vhr=${vhr:-`echo $now | cut -c 9-10`}

LOGDIR=${LOGDIR:-"/lfs/h2/emc/ptmp/${USER}/output/realtime"}
mkdir -p $LOGDIR
cd $LOGDIR

module reset

LINE_TYPES="nbrcnt nbrctc"

for x in ${LINE_TYPES}; do
    echo "submitting jevs_cam_severe_plots.sh for ${x} linetype at ${vhr}Z"
    qsub -v vhr=$vhr,LINE_TYPE=$x ${RRFSevs}/dev/drivers/scripts/plots/cam/jevs_cam_severe_${x}_plots_last31days.sh
    sleep 1
done
sleep 1

exit

