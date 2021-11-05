#!/usr/bin/env bash
if [ -z "${AcessKey}" ];then
    echo "AcessKey is empty"
    exit 1
fi
if [ -z "${SecretKey}" ];then
    echo "AcessKey is empty"
    exit 1
fi
if [ -z "${S3_BUCKET}" ];then
    echo "S3_BUCKET is empty"
    exit 1
fi
if [ -z "${S3_TENACID}" ];then
    echo "S3_TENACID is empty"
    exit 1
fi
if [ -z "${S3_REGION}" ];then
    echo "S3_REGION is empty"
    exit 1
fi

# /mnt/s3
if [ ! -d "/mnt/s3" ];then
    mkdir /mnt/s3
    touch /mnt/s3/test-file-mount
fi

# Set Samba Root Password and Start Samba
(echo ${Samba_Password}; echo ${Samba_Password}) | smbpasswd -s -a root
service smbd start

# Start Nginx
service nginx start

# NFS
echo
echo "${AcessKey}:${SecretKey}" > /etc/passwd-s3fs
chmod 600 /etc/passwd-s3fs
echo
echo "Mounting..."
ARGS=(
    -o allow_other
    -o nonempty
    # -o dbglevel=info
    # -o curldbg
)
s3fs "${S3_BUCKET}" /mnt/s3 -o url="https://${S3_TENACID}.compat.objectstorage.${S3_REGION}.oraclecloud.com/" -o passwd_file=/etc/passwd-s3fs -o use_path_request_style -o nomultipart "${ARGS[@]}"
if [ -e "/mnt/s3/test-file-mount" ];then
    echo "s3fs mount failed"
    exit 1
else
    echo
    echo "s3fs mount success"
    echo
    echo "SMB/Samaba Share:"
    echo "$(curl https://api.ipify.org/)/s3"
    echo
    echo "HTTP Request"
    echo "http://$(curl https://api.ipify.org/)/"
fi

while true; do
    if ! service smbd status;then
        echo "Restarting samba"
        service smbd start
    fi
    if ! service nginx status;then
        echo "Restarting nginx"
        service nginx start
    fi
    sleep 10
done
exit 0