FROM ubuntu:latest
ENV DEBIAN_FRONTEND="noninteractive"
RUN apt update && apt install -y automake autotools-dev fuse g++ git libcurl4-gnutls-dev libfuse-dev libssl-dev libxml2-dev make pkg-config curl
RUN git clone https://github.com/s3fs-fuse/s3fs-fuse.git && \
  cd s3fs-fuse && \
  ./autogen.sh && \
  ./configure --prefix=/usr --with-openssl && \
  make && \
  make install && \
  cd .. && rm -rfv s3fs-fuse
# Install Samba and remove config files
RUN apt install -y samba && rm -rf /etc/samba/smb.conf
# Install Nginx and remove config files
RUN apt install -y nginx && rm -rf /etc/nginx/sites-available/default
ENV \
  AcessKey="" \
  SecretKey="" \
  S3_BUCKET="" \
  S3_TENACID="" \
  S3_REGION="" \
  Samba_Password="samba123"

COPY ./root_folder/ /
RUN chmod a+x /start.sh
ENTRYPOINT [ "/start.sh" ]
