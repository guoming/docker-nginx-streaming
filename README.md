# 安装
```bash
docker run --name nginx-streaming -d \   
    -env LIVE_STREAM_NAMES=live \
    -p 1935:1935 \
    -p 8080:8080  \ 
    --volume /mnt/video/vod:/usr/local/var/www/vod \
    --volume /mnt/video/live:/usr/local/var/www/live \
    geniusming/nginx-streaming:latest
```
# RTMP
 ffmpeg rtmp 推流
```bash
ffmpeg -re -i <video path> -vcodec libx264 -acodec aac -strict -2 -f flv rtmp://127.0.0.1/live/<live stream name>
```
RTMP 地址
rtmp://127.0.0.1/live/<live stream name>    
rtmp://127.0.0.1/vod/<vod stream name>

# HLS
http://127.0.0.1:8080/live/<live stream name>
    
http://127.0.0.1:8080/live/<vod stream name>
