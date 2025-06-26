#!/bin/bash
# Authors: M.G. Caron & L.C. Dawson
#
###########################################################
# Called on a cron to run EVS jobs                        #
###########################################################

now=`date -u +%Y%m%d%H`
vhr=${vhr:-`echo $now | cut -c 9-10`}

LOGDIR=${LOGDIR:-"/lfs/h2/emc/ptmp/${USER}/output/retros/${retro_name}"}
mkdir -p $LOGDIR
cd $LOGDIR

module reset

echo "submitting jevs_cam_severe_prep.sh for ${VDATE}${vhr}"
qsub -v vhr=$vhr,VDATE=$VDATE,IDATE=$IDATE,OTLK_DATE=$OTLK_DATE,retro_name=$retro_name,COMINccpa=$COMINccpa,COMINobsproc=$COMINobsproc,DCOMINmrms=$DCOMINmrms,DCOMINspc=$DCOMINspc,COMINnam=$COMINnam,COMINhrrr=$COMINhrrr,COMINhiresw=$COMINhiresw,COMINrrfs=$COMINrrfs ${RRFSevs}/dev/drivers/scripts/prep/cam/jevs_cam_severe_prep.sh
sleep 1

exit

