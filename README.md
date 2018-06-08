# 安装
docker run --name nginx-streaming -d \
    --env 'RTMP_STREAM_NAMES=live' \ 
    --volume /mnt/video/vod:/usr/local/var/www/vod \
    --volume /mnt/video/live:/usr/local/var/www/live \
    geniusming/streaming:latest
