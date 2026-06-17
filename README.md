# 🚀 Julpone High-Performance Xray-Core Service via Google Cloud Run

A robust, high-speed, and stable Xray-core deployment optimized for Google Cloud Run using a high-performance Nginx Reverse Proxy. This repository supports **Trojan, VMess, VLESS, and Shadowsocks** protocols running seamlessly over both **WebSocket (WS) and HTTPUpgrade (HU)** network transports.

---

## 🛠️ Repository Architecture

The project consists of three core configurations specifically engineered to bypass Google Cloud internal network constraints and handle heavy streaming traffic:

1. **`Dockerfile`**: Built on Alpine Linux with temporary root privileges (`USER root`) to install Nginx, handle directory configurations, and safely rename the core executable process to `panares`.
2. **`config.json`**: Features a robust multi-protocol structure bound to `0.0.0.0` (instead of 127.0.0.1) to allow unrestricted outbound data flow from the isolated container network.
3. **`nginx.conf`**: A high-efficiency proxy bridge acting on Port `8080`. It disables internal caching and stream buffering (`proxy_buffering off`) to eliminate lag, minimize ping, and prevent connection drops during heavy data transfers or video streaming.

---

## 🚀 Cloud Run Optimization Settings

For a 100% stable deployment without performance degradation or early timeouts, ensure the following settings are configured under your **Google Cloud Run Service Settings**:

*   **Container Port:** `8080` (The Nginx listener port)
*   **CPU Allocation:** Select **"CPU is always allocated"**. This prevents the container from sleeping when idle, eliminating connection delay.
*   **Memory:** Allocate `1 GiB` or `2 GiB` for maximum throughput and hardware scaling.
*   **Request Timeout:** Extend this setting from the default `300` seconds to **`3600`** seconds (1 Hour) to prevent Google from terminating active VPN streams.

---

## 📱 VPN Client Configuration Profiles

Use these details to import your configs into mobile or desktop clients like **v2rayNG, NapsternetV, Shadowrocket, or NekoBox**.

> 💡 **Important:** Replace `YOUR-CLOUD-RUN-DOMAIN.a.run.app` with your actual service URL. Google Cloud automatically handles TLS/HTTPS termination, so your external **Port is always 443** and **TLS must be ON**.

### 1. VLESS WebSocket (WS) - *Most Stable Connection*
*   **Protocol:** `VLESS`
*   **Address / Host:** `YOUR-CLOUD-RUN-DOMAIN.a.run.app`
*   **Port:** `443`
*   **User ID (UUID):** `julpone-freenet` *(Input as text ID since the parser relies on this exact string format)*
*   **Encryption:** `none`
*   **Transport / Network:** `ws` (or `websocket`)
*   **Path:** `/vless-julpone-freenet`
*   **TLS:** `Enabled` (ON)
*   **SNI / ServerName:** `YOUR-CLOUD-RUN-DOMAIN.a.run.app` *(Or your active ISP bug host)*

#### 📋 Direct Import Configuration URI (WS Link):
```text
vless://julpone-freenet@YOUR-CLOUD-RUN-DOMAIN.a.run.app:443?encryption=none&security=tls&sni=YOUR-CLOUD-RUN-DOMAIN.a.run.app&type=ws&path=%2Fvless-julpone-freenet#Julpone%20VLESS%20WS
```

---

### 2. TROJAN (HTTPUpgrade) - *Best Data Throughput*
*   **Protocol:** `Trojan`
*   **Address / Host:** `YOUR-CLOUD-RUN-DOMAIN.a.run.app`
*   **Port:** `443`
*   **Password:** `julpone-freenet`
*   **Transport / Network:** `httpupgrade`
*   **Path:** `/julpone-freenet-hu`
*   **TLS:** `Enabled` (ON)
*   **SNI / ServerName:** `YOUR-CLOUD-RUN-DOMAIN.a.run.app`

---

### 3. VLESS (HTTPUpgrade)
*   **Protocol:** `VLESS`
*   **Address / Host:** `YOUR-CLOUD-RUN-DOMAIN.a.run.app`
*   **Port:** `443`
*   **User ID (UUID):** `julpone-freenet`
*   **Encryption:** `none`
*   **Transport / Network:** `httpupgrade`
*   **Path:** `/vless-julpone-freenet-hu`
*   **TLS:** `Enabled` (ON)

---

### 4. SHADOWSOCKS (HTTPUpgrade)
*   **Protocol:** `Shadowsocks (SS)`
*   **Address / Host:** `YOUR-CLOUD-RUN-DOMAIN.a.run.app`
*   **Port:** `443`
*   **Password:** `julpone-freenet`
*   **Encrypt Method:** `aes-256-gcm`
*   **Transport / Network:** `httpupgrade`
*   **Path:** `/ss-julpone-freenet-hu`
*   **TLS:** `Enabled` (ON)

---

## ⚡ Network Stability Tips

1. **Keep-Alive Configuration:** Inside your VPN client app settings, change the **"Connection keep-alive interval"** or **"Ping interval"** from `0` to `15s` or `20s`. This constantly pings the server, forcing the Google Cloud Load Balancer to keep the session alive even during idle periods.
2. **WebSocket Alternatives:** If you want to use the alternative WebSocket (WS) versions of Trojan, VMess, or Shadowsocks, simply alter the client app **Transport** setting to `ws` and remove the `-hu` suffix from the **Path** field (e.g., `/ss-julpone-freenet-hu` becomes `/ss-julpone-freenet`).

---
🔒 **License & Security Note:** For educational and server-optimization research. Enjoy your fast, custom private connection proxy!
