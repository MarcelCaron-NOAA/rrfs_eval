#!/bin/bash
# Authors: M.G. Caron & L.C. Dawson
#
###########################################################
# Called on a cron to run EVS jobs                        #
###########################################################

set -x

now=`date -u +%Y%m%d%H`
vhr=${vhr:-`echo $now | cut -c 9-10`}
models=${models:-"rrfs"}

LOGDIR=${LOGDIR:-"/lfs/h2/emc/ptmp/${USER}/output/retros/${retro_name}"}
mkdir -p $LOGDIR
cd $LOGDIR

module reset

for model in ${models}; do
    echo "submitting jevs_cam_*_severe_stats.sh for ${VDATE}${vhr}"
    qsub -v vhr=$vhr,VDATE=$VDATE,retro_name=$retro_name,COMINccpa=$COMINccpa,COMINobsproc=$COMINobsproc,DCOMINmrms=$DCOMINmrms,DCOMINsnow=$DCOMINsnow,COMINnam=$COMINnam,COMINhrrr=$COMINhrrr,COMINhiresw=$COMINhiresw,COMINrrfs=$COMINrrfs ${RRFSevs}/dev/drivers/scripts/stats/cam/jevs_cam_${model}_severe_stats.sh
done
sleep 1

exit

