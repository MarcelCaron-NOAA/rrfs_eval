#!/bin/bash
# Authors: M.G. Caron & L.C. Dawson
#
###########################################################
# Called on a cron to run EVS jobs                        #
###########################################################

set -x

now=`date -u +%Y%m%d%H`
hh=`echo $now | cut -c 9-10`

ml prod_util
PDYm1=`$NDATE -24 ${now} | cut -c 1-8`
LOGDIR=${LOGDIR:-"/lfs/h2/emc/ptmp/${USER}/output/realtime"}
mkdir -p $LOGDIR
cd $LOGDIR

models=${models:-"rrfs"}

if [ $hh -lt 06 ]; then
   vhr=${vhr:-00}
   models="${models}"
elif [ $hh -ge 06 ] && [ $hh -lt 12 ]; then
   vhr=${vhr:-06}
   if [[ $models == *"hrrr"* ]] && [[ $models == *"namnest"* ]] && [[ $models == *"rrfs"* ]]; then
       models="namnest hrrr rrfs"
   elif [[ $models == *"hrrr"* ]] && [[ $models == *"namnest"* ]]; then
       models="namnest hrrr"
   elif [[ $models == *"hrrr"* ]] && [[ $models == *"rrfs"* ]]; then
       models="hrrr rrfs"
   elif [[ $models == *"namnest"* ]] && [[ $models == *"rrfs"* ]]; then
       models="namnest rrfs"
   elif [[ $models == *"hrrr"* ]]; then
       models="hrrr"
   elif [[ $models == *"namnest"* ]]; then
       models="namnest"
   elif [[ $models == *"rrfs"* ]]; then
       models="rrfs"
   else
       models=""
   fi
elif [ $hh -ge 12 ] && [ $hh -lt 18 ]; then
   vhr=${vhr:-12}
   models="${models}"
elif [ $hh -ge 18 ]; then
   vhr=${vhr:-18}
   if [[ $models == *"hrrr"* ]] && [[ $models == *"namnest"* ]] && [[ $models == *"rrfs"* ]]; then
       models="namnest hrrr rrfs"
   elif [[ $models == *"hrrr"* ]] && [[ $models == *"namnest"* ]]; then
       models="namnest hrrr"
   elif [[ $models == *"hrrr"* ]] && [[ $models == *"rrfs"* ]]; then
       models="hrrr rrfs"
   elif [[ $models == *"namnest"* ]] && [[ $models == *"rrfs"* ]]; then
       models="namnest rrfs"
   elif [[ $models == *"hrrr"* ]]; then
       models="hrrr"
   elif [[ $models == *"namnest"* ]]; then
       models="namnest"
   elif [[ $models == *"rrfs"* ]]; then
       models="rrfs"
   else
       models=""
   fi
else
   echo "vhr will not be defined correctly. Exiting."
   exit
fi

for model in ${models}; do
       echo "submitting jevs_${model}_severe_prep.sh for ${vhr}Z"
       qsub -v vhr=$vhr,COMINccpa=$COMINccpa,COMINobsproc=$COMINobsproc,DCOMINmrms=$DCOMINmrms,COMINnam=$COMINnam,COMINhrrr=$COMINhrrr,COMINhiresw=$COMINhiresw,COMINrrfs=$COMINrrfs ${RRFSevs}/dev/drivers/scripts/prep/cam/jevs_cam_${model}_severe_prep.sh
done
sleep 1

exit

