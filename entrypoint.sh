#!/bin/bash

echo "🚀 Booting up JULPONE Multi-Engine Routing Subsystem..."

# 1. Patakbuhin ang Xray (panares) core sa background loop
/usr/bin/panares -config /etc/xray/config.json &

echo "⚙️ Handing over execution to native Layer 4 HAProxy engine..."

# 2. Gamitin ang exec upang ang HAProxy ang maging PID 1 process (Kailangan ng Cloud Run!)
exec haproxy -f /usr/local/etc/haproxy/haproxy.cfg -db
