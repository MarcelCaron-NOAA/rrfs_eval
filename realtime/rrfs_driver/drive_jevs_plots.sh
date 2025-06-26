#!/bin/bash
#
###########################################################
# Called on a cron to run EVS jobs                        #
###########################################################

set -x

now=`date -u +%Y%m%d%H`
vhr=${vhr:-`echo $now | cut -c 9-10`}

# Default, run all for jobs
run_precip=${run_precip:-1}
run_snowfall=${run_snowfall:-1}
run_grid2obs=${run_grid2obs:-1}

LOGDIR=${LOGDIR:-"/lfs/h2/emc/ptmp/${USER}/output/realtime"}
mkdir -p $LOGDIR
cd $LOGDIR

module reset

echo "submitting jevs_cam_*_plots.sh using ${vhr}Z"
[[ "$run_precip" == "1" ]] && { \
    qsub -v vhr=$vhr ${RRFSevs}/dev/drivers/scripts/plots/cam/jevs_cam_precip_plots_last31days.sh; \
    qsub -v vhr=$vhr ${RRFSevs}/dev/drivers/scripts/plots/cam/jevs_cam_precip_plots_last90days.sh; \
}
[[ "$run_snowfall" == "1" ]] && { \
    qsub -v vhr=$vhr ${RRFSevs}/dev/drivers/scripts/plots/cam/jevs_cam_snowfall_plots.sh; \
}
[[ "$run_grid2obs" == "1" ]] && { \
    qsub -v vhr=$vhr ${RRFSevs}/dev/drivers/scripts/plots/cam/jevs_cam_grid2obs_plots_last31days.sh; \
    qsub -v vhr=$vhr ${RRFSevs}/dev/drivers/scripts/plots/cam/jevs_cam_grid2obs_plots_last90days.sh; \
}
sleep 1
exit

