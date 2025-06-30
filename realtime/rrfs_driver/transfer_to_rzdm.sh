#PBS -N rzdm_rrfs_transfer
#PBS -q "dev_transfer"
#PBS -l select=1:ncpus=1
#PBS -A VERF-DEV
#PBS -l walltime=06:00:00
#PBS -l debug=true
#PBS -V

# Redirect stdout and stderr manually
LOGDIR=${LOGDIR:-"/lfs/h2/emc/stmp/${USER}"}
mkdir -p "$LOGDIR"
exec > "$LOGDIR/log_transfer_rrfs_rzdm.out" 2>&1

echo "Running as user: $USER"

module load rsync/3.2.2
#eval $(ssh-agent -s)
#ssh-add ~/.ssh/id_rsa

PDYm1=$(date -d "-1 day" +"%Y%m%d")
PDYm2=$(date -d "-2 day" +"%Y%m%d")
PDYm3=$(date -d "-3 day" +"%Y%m%d")
PDYm4=$(date -d "-4 day" +"%Y%m%d")
PDYm5=$(date -d "-5 day" +"%Y%m%d")
PDYm6=$(date -d "-6 day" +"%Y%m%d")
PDYm7=$(date -d "-7 day" +"%Y%m%d")
PDYm8=$(date -d "-8 day" +"%Y%m%d")
# All plots jobs use PDYm1, but some may complete on PDYp1, in which case the transfer below will use PDYm2
if [ "$verif_case" = "snowfall" ]; then
    transfer_string="snowfall_$PDYm1"
    file_path="/lfs/h2/emc/ptmp/${USER}/evs/v2.0/realtime/plots/cam/atmos.${PDYm1}/evs.plots.cam.atmos.snowfall.v${PDYm1}.tar"
    if [ ! -s "${LOGOUT}/snowfall_rrfs_transfer.txt" ]; then
        echo "" > ${LOGOUT}/snowfall_rrfs_transfer.txt
    fi
    if ! grep -q $transfer_string "${LOGOUT}/snowfall_rrfs_transfer.txt"; then
        if [ -s $file_path ]; then
            rsync -ahr -P $file_path ${rzdmuser}@emcrzdm.ncep.noaa.gov:/home/people/emc/www/htdocs/users/verification/regional/cam/expr/det/tar_files/.
            echo "$transfer_string" > ${LOGOUT}/snowfall_rrfs_transfer.txt
        else
            echo "The file does not exist: $file_path"
        fi
    else
        echo "$transfer_string has already been transferred."
    fi
fi
if [ "$verif_case" = "precip" ]; then
    transfer_string="precip31_$PDYm1"
    file_path="/lfs/h2/emc/ptmp/${USER}/evs/v2.0/realtime/plots/cam/atmos.${PDYm1}/evs.plots.cam.atmos.precip.last31days.v${PDYm1}.tar"
    if [ ! -s "${LOGOUT}/precip31_rrfs_transfer.txt" ]; then
        echo "" > ${LOGOUT}/precip31_rrfs_transfer.txt
    fi
    if ! grep -q $transfer_string "${LOGOUT}/precip31_rrfs_transfer.txt"; then
        if [ -s $file_path ]; then
            rsync -ahr -P $file_path ${rzdmuser}@emcrzdm.ncep.noaa.gov:/home/people/emc/www/htdocs/users/verification/regional/cam/expr/det/tar_files/.
            echo "$transfer_string" > ${LOGOUT}/precip31_rrfs_transfer.txt
        else
            echo "The file does not exist: $file_path"
        fi
    else
        echo "$transfer_string has already been transferred."
    fi
    transfer_string="precip90_$PDYm1"
    file_path="/lfs/h2/emc/ptmp/${USER}/evs/v2.0/realtime/plots/cam/atmos.${PDYm1}/evs.plots.cam.atmos.precip.last90days.v${PDYm1}.tar"
    if [ ! -s "${LOGOUT}/precip90_rrfs_transfer.txt" ]; then
        echo "" > ${LOGOUT}/precip90_rrfs_transfer.txt
    fi
    if ! grep -q $transfer_string "${LOGOUT}/precip90_rrfs_transfer.txt"; then
        if [ -s $file_path ]; then
            rsync -ahr -P $file_path ${rzdmuser}@emcrzdm.ncep.noaa.gov:/home/people/emc/www/htdocs/users/verification/regional/cam/expr/det/tar_files/.
            echo "$transfer_string" > ${LOGOUT}/precip90_rrfs_transfer.txt
        else
            echo "The file does not exist: $file_path"
        fi
    else
        echo "$transfer_string has already been transferred."
    fi
fi
if [ "$verif_case" = "grid2obs" ]; then
    transfer_string="grid2obs31_$PDYm1"
    file_path="/lfs/h2/emc/ptmp/${USER}/evs/v2.0/realtime/plots/cam/atmos.${PDYm1}/evs.plots.cam.atmos.grid2obs.last31days.v${PDYm1}.tar"
    if [ ! -s "${LOGOUT}/grid2obs31_rrfs_transfer.txt" ]; then
        echo "" > ${LOGOUT}/grid2obs31_rrfs_transfer.txt
    fi
    if ! grep -q $transfer_string "${LOGOUT}/grid2obs31_rrfs_transfer.txt"; then
        if [ -s $file_path ]; then
            rsync -ahr -P $file_path ${rzdmuser}@emcrzdm.ncep.noaa.gov:/home/people/emc/www/htdocs/users/verification/regional/cam/expr/det/tar_files/.
            echo "$transfer_string" > ${LOGOUT}/grid2obs31_rrfs_transfer.txt
        else
            echo "The file does not exist: $file_path"
        fi
    else
        echo "$transfer_string has already been transferred."
    fi
    transfer_string="grid2obs90_$PDYm1"
    file_path="/lfs/h2/emc/ptmp/${USER}/evs/v2.0/realtime/plots/cam/atmos.${PDYm1}/evs.plots.cam.atmos.grid2obs.last90days.v${PDYm1}.tar"
    if [ ! -s "${LOGOUT}/grid2obs90_rrfs_transfer.txt" ]; then
        echo "" > ${LOGOUT}/grid2obs90_rrfs_transfer.txt
    fi
    if ! grep -q $transfer_string "${LOGOUT}/grid2obs90_rrfs_transfer.txt"; then
        if [ -s $file_path ]; then
            rsync -ahr -P $file_path ${rzdmuser}@emcrzdm.ncep.noaa.gov:/home/people/emc/www/htdocs/users/verification/regional/cam/expr/det/tar_files/.
            echo "$transfer_string" > ${LOGOUT}/grid2obs90_rrfs_transfer.txt
        else
            echo "The file does not exist: $file_path"
        fi
    else
        echo "$transfer_string has already been transferred."
    fi
fi
if [ "$verif_case" = "radar" ]; then
    radar_cnt=0
    for line_type in nbrcnt nbrctc; do
        for eval_pd in last31days last90days; do
            transfer_string="radar${radar_cnt}_$PDYm2"
            file_path="/lfs/h2/emc/ptmp/${USER}/evs/v2.0/realtime/plots/cam/atmos.${PDYm2}/evs.plots.cam.atmos.radar_${line_type}.${eval_pd}.v${PDYm2}.tar"
            if [ ! -s "${LOGOUT}/radar_rrfs_transfer.txt" ]; then
                echo "" > ${LOGOUT}/radar_rrfs_transfer.txt
            fi
            if ! grep -q $transfer_string "${LOGOUT}/radar_rrfs_transfer.txt"; then
                if [ -s $file_path ]; then
                    rsync -ahr -P $file_path ${rzdmuser}@emcrzdm.ncep.noaa.gov:/home/people/emc/www/htdocs/users/verification/regional/cam/expr/det/tar_files/.
                    echo "$transfer_string" > ${LOGOUT}/radar_rrfs_transfer.txt
                else
                    echo "The file does not exist: $file_path"
                fi
            else
                echo "$transfer_string has already been transferred."
            fi
            ((radar_cnt++))
        done
    done
fi
if [ "$verif_case" = "severe" ]; then
    severe_cnt=0
    for line_type in nbrcnt nbrctc; do
        for eval_pd in last31days last90days; do
            transfer_string="severe${severe_cnt}_$PDYm7"
            file_path="/lfs/h2/emc/ptmp/${USER}/evs/v2.0/realtime/plots/cam/atmos.${PDYm7}/evs.plots.cam.atmos.severe_${line_type}.${eval_pd}.v${PDYm7}.tar"
            if [ ! -s "${LOGOUT}/severe_rrfs_transfer.txt" ]; then
                echo "" > ${LOGOUT}/severe_rrfs_transfer.txt
            fi
            if ! grep -q $transfer_string "${LOGOUT}/severe_rrfs_transfer.txt"; then
                if [ -s $file_path ]; then
                    rsync -ahr -P $file_path ${rzdmuser}@emcrzdm.ncep.noaa.gov:/home/people/emc/www/htdocs/users/verification/regional/cam/expr/det/tar_files/.
                    echo "$transfer_string" > ${LOGOUT}/severe_rrfs_transfer.txt
                else
                    echo "The file does not exist: $file_path"
                fi
            else
                echo "$transfer_string has already been transferred."
            fi
            ((severe_cnt++))
        done
    done
fi
if [ "$verif_case" = "firewx" ]; then
    transfer_string="firewx_$PDYm1"
    file_path="/lfs/h2/emc/ptmp/${USER}/evs/v2.0/realtime/plots/cam/atmos.${PDYm1}/evs.plots.firewxnest.atmos.grid2obs.last31days.v${PDYm1}.tar"
    if [ ! -s "${LOGOUT}/firewx_rrfs_transfer.txt" ]; then
        echo "" > ${LOGOUT}/firewx_rrfs_transfer.txt
    fi
    if ! grep -q $transfer_string "${LOGOUT}/firewx_rrfs_transfer.txt"; then
        if [ -s $file_path ]; then
            rsync -ahr -P $file_path ${rzdmuser}@emcrzdm.ncep.noaa.gov:/home/people/emc/www/htdocs/users/verification/regional/cam/expr/det/tar_files/.
            echo "$transfer_string" > ${LOGOUT}/firewx_rrfs_transfer.txt
        else
            echo "The file does not exist: $file_path"
        fi
    else
        echo "$transfer_string has already been transferred."
    fi
fi
