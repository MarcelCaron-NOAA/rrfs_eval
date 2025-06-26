#PBS -N rzdm_rrfs_transfer
#PBS -o /lfs/h2/emc/stmp/marcel.caron/log_transfer_rrfs_rzdm.out
#PBS -e /lfs/h2/emc/stmp/marcel.caron/log_transfer_rrfs_rzdm.out
#PBS -q "dev_transfer"
#PBS -l select=1:ncpus=1
#PBS -A VERF-DEV
#PBS -l walltime=06:00:00
#PBS -l debug=true
#PBS -V

module load rsync/3.2.2
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
    transfer_string="snowfall_$PDYm2"
    file_path="/lfs/h2/emc/ptmp/marcel.caron/evs/v1.0/plots/cam/atmos.${PDYm2}/evs.plots.cam.atmos.snowfall.v${PDYm2}.tar"
    if [ ! -s "$HOME/snowfall_rrfs_transfer.txt" ]; then
        echo "" > $HOME/snowfall_rrfs_transfer.txt
    fi
    if ! grep -q $transfer_string "$HOME/snowfall_rrfs_transfer.txt"; then
        if [ -s $file_path ]; then
            rsync -ahr -P $file_path mcaron@emcrzdm.ncep.noaa.gov:/home/people/emc/www/htdocs/users/verification/regional/cam/expr/det/tar_files/.
            echo "$transfer_string" > $HOME/snowfall_rrfs_transfer.txt
        else
            echo "The file does not exist: $file_path"
        fi
    else
        echo "$transfer_string has already been transferred."
    fi
fi
if [ "$verif_case" = "precip" ]; then
    transfer_string="precip_$PDYm2"
    file_path="/lfs/h2/emc/ptmp/marcel.caron/evs/v1.0/plots/cam/atmos.${PDYm2}/evs.plots.cam.atmos.precip.v${PDYm2}.tar"
    if [ ! -s "$HOME/precip_rrfs_transfer.txt" ]; then
        echo "" > $HOME/precip_rrfs_transfer.txt
    fi
    if ! grep -q $transfer_string "$HOME/precip_rrfs_transfer.txt"; then
        if [ -s $file_path ]; then
            rsync -ahr -P $file_path mcaron@emcrzdm.ncep.noaa.gov:/home/people/emc/www/htdocs/users/verification/regional/cam/expr/det/tar_files/.
            echo "$transfer_string" > $HOME/precip_rrfs_transfer.txt
        else
            echo "The file does not exist: $file_path"
        fi
    else
        echo "$transfer_string has already been transferred."
    fi
fi
if [ "$verif_case" = "grid2obs" ]; then
    transfer_string="grid2obs_$PDYm2"
    file_path="/lfs/h2/emc/ptmp/marcel.caron/evs/v1.0/plots/cam/atmos.${PDYm2}/evs.plots.cam.atmos.grid2obs.v${PDYm2}.tar"
    if [ ! -s "$HOME/grid2obs_rrfs_transfer.txt" ]; then
        echo "" > $HOME/grid2obs_rrfs_transfer.txt
    fi
    if ! grep -q $transfer_string "$HOME/grid2obs_rrfs_transfer.txt"; then
        if [ -s $file_path ]; then
            rsync -ahr -P $file_path mcaron@emcrzdm.ncep.noaa.gov:/home/people/emc/www/htdocs/users/verification/regional/cam/expr/det/tar_files/.
            echo "$transfer_string" > $HOME/grid2obs_rrfs_transfer.txt
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
            transfer_string="radar${radar_cnt}_$PDYm3"
            file_path="/lfs/h2/emc/ptmp/marcel.caron/evs/v1.0/plots/cam/atmos.${PDYm3}/evs.plots.cam.atmos.radar_${line_type}.${eval_pd}.v${PDYm3}.tar"
            if [ ! -s "$HOME/radar_rrfs_transfer.txt" ]; then
                echo "" > $HOME/radar_rrfs_transfer.txt
            fi
            if ! grep -q $transfer_string "$HOME/radar_rrfs_transfer.txt"; then
                if [ -s $file_path ]; then
                    rsync -ahr -P $file_path mcaron@emcrzdm.ncep.noaa.gov:/home/people/emc/www/htdocs/users/verification/regional/cam/expr/det/tar_files/.
                    echo "$transfer_string" > $HOME/radar_rrfs_transfer.txt
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
            transfer_string="severe${severe_cnt}_$PDYm8"
            file_path="/lfs/h2/emc/ptmp/marcel.caron/evs/v1.0/plots/cam/atmos.${PDYm8}/evs.plots.cam.atmos.severe_${line_type}.${eval_pd}.v${PDYm8}.tar"
            if [ ! -s "$HOME/severe_rrfs_transfer.txt" ]; then
                echo "" > $HOME/severe_rrfs_transfer.txt
            fi
            if ! grep -q $transfer_string "$HOME/severe_rrfs_transfer.txt"; then
                if [ -s $file_path ]; then
                    rsync -ahr -P $file_path mcaron@emcrzdm.ncep.noaa.gov:/home/people/emc/www/htdocs/users/verification/regional/cam/expr/det/tar_files/.
                    echo "$transfer_string" > $HOME/severe_rrfs_transfer.txt
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
    transfer_string="firewx_$PDYm2"
    file_path="/lfs/h2/emc/ptmp/marcel.caron/evs/v1.0/plots/cam/atmos.${PDYm2}/evs.plots.firewxnest.atmos.grid2obs.last31days.v${PDYm2}.tar"
    if [ ! -s "$HOME/firewx_rrfs_transfer.txt" ]; then
        echo "" > $HOME/firewx_rrfs_transfer.txt
    fi
    if ! grep -q $transfer_string "$HOME/firewx_rrfs_transfer.txt"; then
        if [ -s $file_path ]; then
            rsync -ahr -P $file_path mcaron@emcrzdm.ncep.noaa.gov:/home/people/emc/www/htdocs/users/verification/regional/cam/expr/det/tar_files/.
            echo "$transfer_string" > $HOME/firewx_rrfs_transfer.txt
        else
            echo "The file does not exist: $file_path"
        fi
    else
        echo "$transfer_string has already been transferred."
    fi
fi
