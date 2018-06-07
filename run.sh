#!/bin/sh

NGINX_CONFIG_FILE=/opt/nginx/conf/nginx.conf

LIVE_ROOT_PATH=${LIVE_ROOT_PATH-/usr/local/var/www/live}
VOD_ROOT_PATH=${VOD_ROOT_PATH-/usr/local/var/www/vod}

RTMP_CONNECTIONS=${RTMP_CONNECTIONS-1024}
RTMP_STREAM_NAMES=${RTMP_STREAM_NAMES-live,testing}
RTMP_STREAMS=$(echo ${RTMP_STREAM_NAMES} | sed "s/,/\n/g")
RTMP_PUSH_URLS=$(echo ${RTMP_PUSH_URLS} | sed "s/,/\n/g")


apply_config() {

    echo "Creating config"
## Standard config:

cat >${NGINX_CONFIG_FILE} <<!EOF
worker_processes 1;

events {
    worker_connections ${RTMP_CONNECTIONS};
}
!EOF

## HTTP / HLS Config
cat >>${NGINX_CONFIG_FILE} <<!EOF
http {
    include             mime.types;
    default_type        application/octet-stream;
    sendfile            on;
    keepalive_timeout   65;

    server {
        listen          8080;
        server_name     localhost;

        location /vod {
            types {
                application/vnd.apple.mpegurl m3u8;
                video/mp2ts ts;
            }
            alias ${VOD_ROOT_PATH};
            add_header  Cache-Control no-cache;
        }

        location /live {
            types {
                application/vnd.apple.mpegurl m3u8;
                video/mp2ts ts;
            }
            alias ${LIVE_ROOT_PATH};
            add_header  Cache-Control no-cache;
        }

        location /on_publish {
            return  201;
        }
        location /stat {
            rtmp_stat all;
            rtmp_stat_stylesheet stat.xsl;
        }
        location /stat.xsl {
            root /opt/nginx/conf/stat.xsl;
        }
        location /control {
            rtmp_control all;
        }
        
        error_page  500 502 503 504 /50x.html;
        location = /50x.html {
            root html;
        }
    }
}
        
!EOF


## RTMP Config
cat >>${NGINX_CONFIG_FILE} <<!EOF
rtmp {
    server {
        listen 1935;
        chunk_size 4096;
        application vod {
            play ${VOD_ROOT_PATH};
        }
!EOF

if [ "x${RTMP_PUSH_URLS}" = "x" ]; then
    PUSH="false"
else
    PUSH="true"
fi

HLS="true"

for STREAM_NAME in $(echo ${RTMP_STREAMS}) 
do

echo Creating stream $STREAM_NAME
cat >>${NGINX_CONFIG_FILE} <<!EOF
        application ${STREAM_NAME} {
            live on;
            record off;
            on_publish http://localhost:8080/on_publish;
!EOF
if [ "${HLS}" = "true" ]; then
cat >>${NGINX_CONFIG_FILE} <<!EOF
            hls on;
            hls_path ${LIVE_ROOT_PATH}/${STREAM_NAME};
!EOF
    HLS="false"
fi
    if [ "$PUSH" = "true" ]; then
        for PUSH_URL in $(echo ${RTMP_PUSH_URLS}); do
            echo "Pushing stream to ${PUSH_URL}"
            cat >>${NGINX_CONFIG_FILE} <<!EOF
            push ${PUSH_URL};
!EOF
            PUSH=false
        done
    fi
cat >>${NGINX_CONFIG_FILE} <<!EOF
        }
!EOF
done

cat >>${NGINX_CONFIG_FILE} <<!EOF
    }
}
!EOF
}

if ! [ -f ${NGINX_CONFIG_FILE} ]; then
    apply_config
else
    echo "CONFIG EXISTS - Not creating!"
fi

echo "Starting server..."
/opt/nginx/sbin/nginx -g "daemon off;"

