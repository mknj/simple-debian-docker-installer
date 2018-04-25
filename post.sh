echo '{ "storage-driver": "overlay2" }' >/etc/docker/daemon.json
mkdir -p /etc/systemd/system/docker.service.d/override.conf
# you need to protect port 2375 via docker tls or firewall
cat >/etc/systemd/system/docker.service.d/override.conf <<EOF
[Service]
  ExecStart=
  ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:2375 -H fd://
EOF

systemctl daemon-reload
systemctl restart docker
