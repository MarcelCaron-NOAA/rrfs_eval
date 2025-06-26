#!/bin/bash

# ======================= DESCRIPTION AND HOW TO USE ============================
#
# This script can be used to verify RRFS across a retrospective period.  This header
# script sets the locations of retro forecasts and prepared observation archives,
# EVS jobs to run, and then is able to submit a retrospective version of each
# required EVS job.
#
# (1) Start by identifying the VDATEs (valid dates) that cover the retro period.
# It's not a bad idea to cover more than is necessary.
# (2) Then set COMINrrfs to the directory that contains the retrospective RRFS
# forecasts (i.e., contains "rrfs.YYYYmmdd" subdirectories). Also verify that the 
# directory structure matches what is expected for RRFS in the EVS 
# (i.e., rrfs.YYYYmmdd/HH/[grib2 files])
# (3) Next, set all other COMIN* or DCOMIN* retro settings so that they point to 
# the correct observation archives
# (4) Then set run_final=0, run_prep_*=1, and all other run_*=0
# (5) Check that RRFSevs and CRONOUT are correct and exist
# (6) Execute this script on the command line.  It will call driver scripts that 
# will submit verification jobs to the queue. Beware: If RRFSevs is being set
# in your environment, it will overwrite the value printed here. Therefore, run 
# this script like this: RRFSevs="/lfs/desired/path/etc" this_script.sh
# (7) Wait for prep jobs to complete, then set all run_prep_*=0 and all 
# run_stats_*=1 except for run_stats_severe (=0) and execute this script
# (8) Wait for first set of stats jobs to complete, then set run_final=1, 
# run_stats_severe=1, making sure all other run_stats_*=1, then execute again
# (9) (Optional) Wait for final stats jobs to complete, then set all run_stats_*=0 
# and all run_plots_*=1. Adjust the dates as needed, then execute again

# ======================= USER CONFIGURATION ====================================

# Top-level Retro Settings
USHretro=${USHretro:-"/lfs/h2/emc/vpppg/noscrub/marcel.caron/ush/rrfs_eval/retro"}
retro_name=${retro_name:-"Spring2024"}
models="rrfs" # list mesoscale separately from cam 
#models="hireswarw hireswarwmem2 hireswfv3"
#models="nam"
#models="rrfs"

# Get retro info, like VDATEs and retro data input dir
if [[ "${retro_name}" == "Summer2023" ]]; then
    source $USHretro/summer2023_info.sh
elif [[ "${retro_name}" == "Spring2024" ]]; then
    source $USHretro/spring2024_info.sh
elif [[ "${retro_name}" == "Winter2024" ]]; then
    source $USHretro/winter2024_info.sh
elif [[ "${retro_name}" == "Radiosonde2025A" ]]; then
    source $USHretro/radiosonde2025_info.sh
elif [[ "${retro_name}" == "Radiosonde2025B" ]]; then
    source $USHretro/radiosonde2025_info.sh
else
    echo "WARNING: Not a known retro period: ${retro_name}"
    exit 1
fi
pos=$(( ${#VDATEs[*]} - 1 ))
last=${VDATEs[$pos]}

# Effectively, "HOMEevs"
RRFSevs=${RRFSevs:-"/lfs/h2/emc/vpppg/save/marcel.caron/EVS_rrfs/retro/EVS"}

# Run an EVS job
# 0 - Do not run; 1 - Do run
run_prep_radar=0
run_prep_severe=0
run_prep_severe_model=0
run_prep_precip=0
run_stats_grid2obs=1
run_stats_firewx=0
run_stats_precip=0
run_stats_snowfall=0
run_stats_radar=0
run_stats_severe=0
run_plots_main=0
run_plots_radar=0
run_plots_severe=0

# Run the final vhr in vhrs
# 0 - run all but the final vhr; 1 - run only the final vhr
# For prep - Set to 0
# For stats - Set as needed (exception: for severe stats set to 1)
# For plots - Set to 1
run_final=1

# Other Retro Settings
COMINccpa=${COMINccpa:-"/lfs/h3/emc/lam/noscrub/rrfsv1_eval_meg/retros/${retro_data_dir}/obs"}
COMINobsproc=${COMINobsproc:-"/lfs/h3/emc/lam/noscrub/rrfsv1_eval_meg/retros/${retro_data_dir}/obs"}
COMINmrms_prep=${COMINmrms_prep:-"/lfs/h3/emc/lam/noscrub/rrfsv1_eval_meg/retros/${retro_data_dir}/obs/upperair/mrms"}
COMINmrms_stats=${COMINmrms_stats:-"/lfs/h3/emc/lam/noscrub/rrfsv1_eval_meg/retros/${retro_data_dir}/obs/upperair/mrms/alaska/MultiSensorQPE"}
DCOMINspc=${DCOMINspc:-"/lfs/h3/emc/lam/noscrub/rrfsv1_eval_meg/retros/${retro_data_dir}/obs"}
DCOMINsnow=${DCOMINsnow:-"/lfs/h3/emc/lam/noscrub/rrfsv1_eval_meg/retros/${retro_data_dir}/obs"}
COMINhrrr=${COMINhrrr:-"/lfs/h3/emc/lam/noscrub/rrfsv1_eval_meg/retros/${retro_data_dir}/fcst"}
COMINhiresw=${COMINhiresw:-"/lfs/h3/emc/lam/noscrub/rrfsv1_eval_meg/retros/${retro_data_dir}/fcst"}
COMINnam=${COMINnam:-"/lfs/h3/emc/lam/noscrub/rrfsv1_eval_meg/retros/${retro_data_dir}/fcst"}
COMINrrfs=${COMINrrfs:-"/lfs/h3/emc/lam/noscrub/rrfs_retro_output"}

# Where to write output of driver scripts
CRONOUT="/lfs/h2/emc/stmp/marcel.caron/retro.out"


# ===============================================================================


for VDATE in "${VDATEs[@]}"; do
    VDATEp6=$(date -d "$VDATE +6 day" +"%Y%m%d")
    if [ "$run_prep_radar" -eq "1" ]; then 
        if [ "$run_final" -eq "0" ]; then
            declare -a vhrs=("00" "01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "23")
            for vhr in "${vhrs[@]}"; do
                echo "Running prep radar for ${VDATE}${vhr} (${RRFSevs})"
                retro_name=$retro_name RRFSevs=$RRFSevs vhr=$vhr VDATE=$VDATE models=$models COMINccpa=$COMINccpa COMINobsproc=$COMINobsproc DCOMINmrms=$COMINmrms_prep COMINrrfs=$COMINrrfs COMINhrrr=$COMINhrrr COMINhiresw=$COMINhiresw COMINnam=$COMINnam ${USHretro}/rrfs_driver/drive_jevs_cam_radar_prep.sh >> ${CRONOUT}/retro_jevs_cam_rrfs_radar_prep.out 2>&1 
            done
        fi
    fi
    if [ "$run_prep_severe" -eq "1" ]; then 
        IDATE=$VDATEp6
        OTLK_DATE=$VDATEp6
        if [ "$run_final" -eq "0" ]; then
            declare -a vhrs=("07")
            for vhr in "${vhrs[@]}"; do
                echo "Running prep severe for ${VDATE}${vhr} (${RRFSevs})"
                retro_name=$retro_name RRFSevs=$RRFSevs vhr=$vhr VDATE=$VDATE models=$models IDATE=$IDATE OTLK_DATE=$OTLK_DATE COMINccpa=$COMINccpa COMINobsproc=$COMINobsproc DCOMINmrms=$COMINmrms_prep DCOMINspc=$DCOMINspc COMINrrfs=$COMINrrfs COMINhrrr=$COMINhrrr COMINhiresw=$COMINhiresw COMINnam=$COMINnam ${USHretro}/rrfs_driver/drive_jevs_cam_severe_prep.sh >> ${CRONOUT}/retro_jevs_cam_rrfs_severe_prep.out 2>&1 
            done
        fi
    fi
    if [ "$run_prep_severe_model" -eq "1" ]; then 
        IDATE=$VDATEp6
        OTLK_DATE=$VDATEp6
        if [ "$run_final" -eq "0" ]; then
            declare -a vhrs=("00" "06" "12" "18")
            for vhr in "${vhrs[@]}"; do
                echo "Running prep severe \"model\" for ${VDATE}${vhr} (${RRFSevs})"
                retro_name=$retro_name RRFSevs=$RRFSevs vhr=$vhr VDATE=$VDATE models=$models IDATE=$IDATE OTLK_DATE=$OTLK_DATE COMINccpa=$COMINccpa COMINobsproc=$COMINobsproc DCOMINmrms=$COMINmrms_prep DCOMINspc=$DCOMINspc COMINrrfs=$COMINrrfs COMINhrrr=$COMINhrrr COMINhiresw=$COMINhiresw COMINnam=$COMINnam ${USHretro}/rrfs_driver/drive_jevs_cam_model_severe_prep.sh >> ${CRONOUT}/retro_jevs_cam_rrfs_model_severe_prep.out 2>&1 
            done
        fi
    fi
    if [ "$run_prep_precip" -eq "1" ]; then 
        if [ "$run_final" -eq "0" ]; then
            declare -a vhrs=("00" "06" "12" "18")
            for vhr in "${vhrs[@]}"; do
                echo "Running prep precip for ${VDATE}${vhr} (${RRFSevs})"
                retro_name=$retro_name RRFSevs=$RRFSevs vhr=$vhr VDATE=$VDATE models=$models COMINccpa=$COMINccpa COMINobsproc=$COMINobsproc DCOMINmrms=$COMINmrms_prep COMINrrfs=$COMINrrfs COMINhrrr=$COMINhrrr COMINhiresw=$COMINhiresw COMINnam=$COMINnam ${USHretro}/rrfs_driver/drive_jevs_cam_precip_prep.sh >> ${CRONOUT}/retro_jevs_cam_rrfs_precip_prep.out 2>&1 
            done
        fi
    fi
    if [ "$run_stats_grid2obs" -eq "1" ]; then 
        if [ "$run_final" -eq "0" ]; then
            if [[ "${models}" == *"nam"* ]] && [[ "${models}" != *"namnest"* ]]; then
                declare -a vhrs=("07")
            else
                declare -a vhrs=("02" "03" "06" "09" "12" "15" "18")
            fi
        else
            if [[ "${models}" == *"nam"* ]] && [[ "${models}" != *"namnest"* ]]; then
                declare -a vhrs=()
            else
                declare -a vhrs=("21")
            fi
        fi
        for vhr in "${vhrs[@]}"; do
            echo "Running stats grid2obs for ${VDATE}${vhr} (${RRFSevs})"
            retro_name=$retro_name RRFSevs=$RRFSevs vhr=$vhr VDATE=$VDATE models=$models COMINccpa=$COMINccpa COMINobsproc=$COMINobsproc DCOMINmrms=$COMINmrms_stats DCOMINsnow=$DCOMINsnow COMINrrfs=$COMINrrfs COMINhrrr=$COMINhrrr COMINhiresw=$COMINhiresw COMINnam=$COMINnam ${USHretro}/rrfs_driver/drive_jevs_grid2obs_stats.sh >> ${CRONOUT}/retro_jevs_cam_rrfs_grid2obs_stats.out 2>&1 
        done
    fi
    if [ "$run_stats_firewx" -eq "1" ]; then 
        if [ "$run_final" -eq "0" ]; then
            declare -a vhrs=("00" "01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22")
        else
            declare -a vhrs=("23")
        fi
        for vhr in "${vhrs[@]}"; do
            echo "Running stats firewx for ${VDATE}${vhr} (${RRFSevs})"
            retro_name=$retro_name RRFSevs=$RRFSevs vhr=$vhr VDATE=$VDATE models=$models COMINccpa=$COMINccpa COMINobsproc=$COMINobsproc DCOMINmrms=$COMINmrms_stats DCOMINsnow=$DCOMINsnow COMINrrfs=$COMINrrfs COMINhrrr=$COMINhrrr COMINhiresw=$COMINhiresw COMINnam=$COMINnam ${USHretro}/rrfs_driver/drive_jevs_cam_firewx_stats.sh >> ${CRONOUT}/retro_jevs_cam_rrfs_firewx_stats.out 2>&1 
        done
    fi
    if [ "$run_stats_precip" -eq "1" ]; then 
        if [ "$run_final" -eq "0" ]; then
            if [[ "${models}" == *"nam"* ]] && [[ "${models}" != *"namnest"* ]]; then
                declare -a vhrs=("00" "01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22")
            else
                declare -a vhrs=("19" "20" "21")
            fi
        else
            if [[ "${models}" == *"nam"* ]] && [[ "${models}" != *"namnest"* ]]; then
                declare -a vhrs=("23")
            else
                declare -a vhrs=("22")
            fi
        fi
        for vhr in "${vhrs[@]}"; do
            echo "Running stats precip for ${VDATE}${vhr} (${RRFSevs})"
            retro_name=$retro_name RRFSevs=$RRFSevs vhr=$vhr VDATE=$VDATE models=$models COMINccpa=$COMINccpa COMINobsproc=$COMINobsproc DCOMINmrms=$COMINmrms_stats DCOMINsnow=$DCOMINsnow COMINrrfs=$COMINrrfs COMINhrrr=$COMINhrrr COMINhiresw=$COMINhiresw COMINnam=$COMINnam ${USHretro}/rrfs_driver/drive_jevs_precip_stats.sh >> ${CRONOUT}/retro_jevs_cam_rrfs_precip_stats.out 2>&1 
        done
    fi
    if [ "$run_stats_snowfall" -eq "1" ]; then 
        if [ "$run_final" -eq "0" ]; then
            declare -a vhrs=("00" "06" "12")
        else
            declare -a vhrs=("18")
        fi
        for vhr in "${vhrs[@]}"; do
            echo "Running stats snowfall for ${VDATE}${vhr} (${RRFSevs})"
            retro_name=$retro_name RRFSevs=$RRFSevs vhr=$vhr VDATE=$VDATE models=$models COMINccpa=$COMINccpa COMINobsproc=$COMINobsproc DCOMINmrms=$COMINmrms_stats DCOMINsnow=$DCOMINsnow COMINrrfs=$COMINrrfs COMINhrrr=$COMINhrrr COMINhiresw=$COMINhiresw COMINnam=$COMINnam ${USHretro}/rrfs_driver/drive_jevs_snowfall_stats.sh >> ${CRONOUT}/retro_jevs_cam_rrfs_snowfall_stats.out 2>&1 
        done
    fi
    if [ "$run_stats_radar" -eq "1" ]; then 
        if [ "$run_final" -eq "0" ]; then
            declare -a vhrs=("00" "01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22")
        else
            declare -a vhrs=("23")
        fi
        for vhr in "${vhrs[@]}"; do
            echo "Running stats radar for ${VDATE}${vhr} (${RRFSevs})"
            retro_name=$retro_name RRFSevs=$RRFSevs vhr=$vhr VDATE=$VDATE models=$models COMINccpa=$COMINccpa COMINobsproc=$COMINobsproc DCOMINmrms=$COMINmrms_stats DCOMINsnow=$DCOMINsnow COMINrrfs=$COMINrrfs COMINhrrr=$COMINhrrr COMINhiresw=$COMINhiresw COMINnam=$COMINnam ${USHretro}/rrfs_driver/drive_jevs_cam_radar_stats.sh >> ${CRONOUT}/retro_jevs_cam_rrfs_radar_stats.out 2>&1 
        done
    fi
    if [ "$run_stats_severe" -eq "1" ]; then 
        if [ "$run_final" -eq "1" ]; then
            declare -a vhrs=("08")
            for vhr in "${vhrs[@]}"; do
                echo "Running stats severe for ${VDATE}${vhr} (${RRFSevs})"
                retro_name=$retro_name RRFSevs=$RRFSevs vhr=$vhr VDATE=$VDATE models=$models COMINccpa=$COMINccpa COMINobsproc=$COMINobsproc DCOMINmrms=$COMINmrms_stats DCOMINsnow=$DCOMINsnow COMINrrfs=$COMINrrfs COMINhrrr=$COMINhrrr COMINhiresw=$COMINhiresw COMINnam=$COMINnam ${USHretro}/rrfs_driver/drive_jevs_cam_severe_stats.sh >> ${CRONOUT}/retro_jevs_cam_rrfs_severe_stats.out 2>&1 
            done
        fi
    fi
    if [[ $VDATE == $last ]]; then # Experiment with this.  If not useful to hard-code last-only RDATE to be run, then remove and rather edit the list of RDATEs.
        if [ "$run_plots_main" -eq "1" ]; then 
            if [ "$run_final" -eq "1" ]; then
                declare -a vhrs=("00")
                for vhr in "${vhrs[@]}"; do
                    echo "Running plots main for ${VDATE}${vhr} (${RRFSevs})"
                    retro_name=$retro_name RRFSevs=$RRFSevs vhr=$vhr VDATE=$VDATE models=$models ${USHretro}/rrfs_driver/drive_jevs_plots.sh >> ${CRONOUT}/retro_jevs_cam_rrfs_plots.out 2>&1 
                done
            fi
        fi
        if [ "$run_plots_radar" -eq "1" ]; then 
            if [ "$run_final" -eq "1" ]; then
                declare -a vhrs=("00")
                for vhr in "${vhrs[@]}"; do
                    echo "Running plots radar for ${VDATE}${vhr} (${RRFSevs})"
                    retro_name=$retro_name RRFSevs=$RRFSevs vhr=$vhr VDATE=$VDATE models=$models ${USHretro}/rrfs_driver/drive_jevs_cam_radar_plots.sh >> ${CRONOUT}/retro_jevs_cam_rrfs_radar_plots.out 2>&1 
                done
            fi
        fi
        if [ "$run_plots_severe" -eq "1" ]; then 
            if [ "$run_final" -eq "1" ]; then
                declare -a vhrs=("00")
                for vhr in "${vhrs[@]}"; do
                    echo "Running plots severe for ${VDATE}${vhr} (${RRFSevs})"
                    retro_name=$retro_name RRFSevs=$RRFSevs vhr=$vhr VDATE=$VDATE models=$models ${USHretro}/rrfs_driver/drive_jevs_cam_severe_plots.sh >> ${CRONOUT}/retro_jevs_cam_rrfs_severe_plots.out 2>&1 
                done
            fi
        fi
    fi
done
