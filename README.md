# 安装
```bash
docker run --name nginx-streaming -d \   
    --volume /mnt/video/vod:/usr/local/var/www/vod \
    --volume /mnt/video/live:/usr/local/var/www/live \
    geniusming/nginx-streaming:latest
```
# RTMP
 ffmpeg rtmp 推流
```bash
ffmpeg -re -i <video path> -vcodec libx264 -acodec aac -strict -2 -f flv rtmp://127.0.0.1/live/<live stream name>
```
VCL Media Play 播放
rtmp://127.0.0.1/live/<live stream name>
rtmp://127.0.0.1/vod/<vod stream name>

# HLS 在线播放
http://127.0.0.1:8080/live/<live stream name>
http://127.0.0.1:8080/live/<vod stream name>
