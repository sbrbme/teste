#!/bin/sh

DATE_TODAY=`date +"%Y%m%d"`
HOUR_NOW=`date +"%H%M%S"`

LOG_PATH=/sasconfig/scripts/Logs

curl -s http://localhost:8680/RTDM/DS2Warmer.jsp > ${LOG_PATH}/DS2Warmer_${DATE_TODAY}_${HOUR_NOW}.log

cd /sasconfig/scripts/Logs

find . -type f -mtime +30 -exec rm -f {} \;