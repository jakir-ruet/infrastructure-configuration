## Overview

A `proxy` server and a `reverse proxy` server are both intermediaries that sit between clients and servers, but they work in opposite directions.

### Proxy Server (Forward Proxy)

A proxy server sits between a client (user) and the internet. The client sends requests to the proxy, and the proxy forwards them to the destination server.

> When you open a website through a proxy

```bash
Client → Proxy Server → Internet Server
Your PC → Proxy → Google
```

> Google sees the **proxy's IP**, not your real IP.

![Proxy Server (Forward Proxy)](/01-servers/06-proxy-rproxy/01-haproxy/img/proxy-server.png)

#### Uses

- Hide client IP (anonymity)
- Bypass geo restrictions
- Content filtering (schools/offices)
- Caching web content

#### Common Forward Proxy Software

- Squid Proxy
- CCProxy
- Apache Traffic Server

### Reverse Proxy Server

A reverse proxy sits in front of web servers and receives requests from clients.
Instead of clients directly contacting the backend server, they talk to the reverse proxy.

```bash
Client → Reverse Proxy → Backend Servers
```

```bash
User → Reverse Proxy → Web Server 1
                         Web Server 2
                         Web Server 3
```

> The reverse proxy decides which server should handle the request.

![Reverse Proxy Server](/01-servers/06-proxy-rproxy/01-haproxy/img/reverse-proxy-server.png)

#### Uses

- Load balancing
- Security (hide backend servers)
- SSL termination
- Caching
- DDoS protection

#### Popular Reverse Proxy Software

- HAProxy
- NGINX
- Apache HTTP Server
- Traefik
- Envoy Proxy

### Comparison

| Feature  | Forward Proxy             | Reverse Proxy            |
| -------- | ------------------------- | ------------------------ |
| Position | Client side               | Server side              |
| Hides    | Client identity           | Server identity          |
| Used by  | Users / internal networks | Websites / cloud systems |
| Example  | Squid                     | HAProxy, NGINX           |

### Easy way to remember

- Forward Proxy = represents the client
- Reverse Proxy = represents the server
