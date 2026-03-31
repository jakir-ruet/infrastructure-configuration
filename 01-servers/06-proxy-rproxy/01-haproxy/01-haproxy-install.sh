sudo apt update
sudo apt install haproxy -y
sudo systemctl enable haproxy

sudo cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.bak
