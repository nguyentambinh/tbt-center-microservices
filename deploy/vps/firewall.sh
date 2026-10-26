#!/bin/bash
# Tường lửa của máy chủ: từ Internet chỉ vào được SSH và Caddy (80, 443).
# ufw lo cổng của chính máy; cổng Docker mở ra đi vòng qua ufw nên chặn thêm ở chuỗi DOCKER-USER,
# cổng NodePort của k3s chặn ở mangle PREROUTING. Container, pod trong máy vẫn gọi nhau bình thường.
# Chạy trên máy chủ: bash deploy/vps/firewall.sh   (cài luôn dịch vụ systemd để tự áp lại sau khi khởi động)
set -euo pipefail
WAN=${WAN:-$(ip route show default | awk '{print $5; exit}')}

ufw --force reset >/dev/null
ufw default deny incoming >/dev/null
ufw default allow outgoing >/dev/null
ufw default allow routed >/dev/null
ufw allow 22/tcp >/dev/null
ufw allow 80/tcp >/dev/null
ufw allow 443/tcp >/dev/null
ufw allow 443/udp >/dev/null
# Pod và Service của k3s gọi API server, kubelet trên máy
ufw allow from 10.42.0.0/16 >/dev/null
ufw allow from 10.43.0.0/16 >/dev/null
# Grafana, Prometheus Hub (trong container) đọc Prometheus DE qua Caddy ở cổng 9190 của docker0
ufw allow from 172.16.0.0/12 to any port 9190 proto tcp >/dev/null
ufw --force enable >/dev/null

cat > /usr/local/sbin/tbt-docker-user.sh <<EOF
#!/bin/bash
# Kết nối mới từ Internet không được đi thẳng vào container hay pod; phản hồi của kết nối cũ vẫn qua
iptables -N DOCKER-USER 2>/dev/null || true
iptables -F DOCKER-USER
iptables -A DOCKER-USER -i $WAN -m conntrack --ctstate ESTABLISHED,RELATED -j RETURN
iptables -A DOCKER-USER -i $WAN -j DROP
iptables -A DOCKER-USER -j RETURN
# NodePort của k3s: chặn ở mangle PREROUTING, trước khi kube-proxy đổi địa chỉ đích sang pod
for proto in tcp udp; do
  iptables -t mangle -D PREROUTING -i $WAN -p \$proto --dport 30000:32767 -j DROP 2>/dev/null || true
  iptables -t mangle -I PREROUTING -i $WAN -p \$proto --dport 30000:32767 -j DROP
done
EOF
chmod +x /usr/local/sbin/tbt-docker-user.sh

cat > /etc/systemd/system/tbt-docker-user.service <<'EOF'
[Unit]
Description=Chặn Internet đi thẳng vào cổng của container và pod
After=docker.service k3s.service
Wants=docker.service

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/tbt-docker-user.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable --now tbt-docker-user.service >/dev/null
systemctl restart tbt-docker-user.service
echo "Tường lửa đã bật trên $WAN: chỉ mở 22, 80, 443"
