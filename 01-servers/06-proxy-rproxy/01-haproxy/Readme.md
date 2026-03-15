## Here We Learn

- HAProxy Terminology
- Types of Load Balancing
- Load Balancing Algorithms
- Sticky Sessions
- Health Check
- High Availability
- Conclusion

### HAProxy Terminology

When working with HAProxy, several core concepts are important for understanding `load balancing and proxying`, including `ACLs`, `frontends`, and `backends`.

#### Access Control List (ACL)

An ACL is used to evaluate conditions and take actions based on request attributes. It enables flexible traffic `routing` or `filtering` using factors like URL `patterns`, `headers`, or `connection counts`, like

```bash
acl url_blog path_beg /blog
```

This rule matches requests whose path begins with `/blog`, such as

```bash
http://yourdomain.com/blog/post1
```

#### Frontend

A frontend defines how HAProxy receives incoming client requests. It specifies the IP address and port that HAProxy listens on.

```bash
frontend web_front
    bind *:80
    default_backend web_servers
```

> **Here**

- HAProxy listens on port `80`
- Requests are forwarded to `web_servers`.

#### Backend

A backend is a group of servers that handle client requests forwarded by HAProxy.

```bash
backend web_servers
    balance roundrobin
    server web1 192.168.1.101:80 check
    server web2 192.168.1.102:80 check
```

> **Important elements**

- balance → load balancing method
- server → backend servers
- check → health monitoring

**NB:** Adding multiple servers improves scalability and fault tolerance.

#### Access Control Lists (ACL)

ACLs allow HAProxy to route traffic based on conditions such as URL paths, headers, or IP addresses.

```bash
acl blog path_beg /blog # use_backend blog_backend if blog
```

> This routes requests beginning with `/blog` to a specific backend.

#### Types of Load Balancing

##### Layer 4 (Transport Layer)

Operates at the TCP/UDP level.

![Layer 4 (Transport Layer)](/01-servers/06-proxy-rproxy/01-haproxy/img/layer_4_load_balancing.png)

**Characteristics**

- Works at the Transport Layer (Layer 4) of the OSI model
- Distributes traffic based on `IP` address and `port` number
- Does not inspect application data (`HTTP headers`, `URLs`, etc.)
- Very fast and efficient because it only handles network-level information
- Commonly used for `TCP-based` services
- Implemented by load balancers like `HAProxy`
- Frequently used for `database` systems such as `PostgreSQL` and `MySQL`
- Suitable for `high-performance` and `high-throughput` environments

**Use case**

- PostgreSQL cluster
- MySQL cluster

Configuration - `cfg`

```bash
mode tcp
```

##### Layer 7 (Application Layer)

Operates at the HTTP level and can inspect requests.

![Layer 7 (Application Layer)](/01-servers/06-proxy-rproxy/01-haproxy/img/layer_7_load_balancing.png)

**Characteristics**

- Header inspection
- Operates at the Application Layer (Layer 7) of the OSI model
- Can route traffic based on request content, such as URL paths, headers, cookies, or HTTP methods
- Allows multiple applications to run on the same domain and port
- Uses ACLs (Access Control Lists) to determine which backend handles a request

Configuration - `cfg`

```bash
mode http
```

```bash
frontend http
  bind *:80
  mode http

  acl url_blog path_beg /blog
  use_backend blog-backend if url_blog

  default_backend web-backend
```

**Explanation**

- `frontend http` → handles incoming requests on port `80`
- `acl url_blog path_beg /blog` → matches requests starting with `/blog`
- `use_backend blog-backend if url_blog` → forwards `/blog` traffic to blog servers
- `default_backend web-backend` → sends all other requests to the main web application
- Ideal for web applications, APIs, and services needing content-aware routing
- Implemented by load balancers like HAProxy and Nginx

**Use case**

- Nginx
- Web applications

##### Load Balancing Algorithms & Sticky Sessions

###### Load Balancing Algorithms in HAProxy

1. Round Robin
   - Default algorithm
   - Distributes requests evenly across all backend servers in turn

2. Leastconn
   - Sends requests to the server with the fewest active connections
   - Recommended for long-lived sessions
   - Servers with equal connections are rotated in round-robin order

3. source
   - Selects a server based on a hash of the client’s IP address
   - Ensures the same user consistently connects to the same server

###### Sticky Sessions (Session Persistence)

- Ensures that a user continues connecting to the same backend server
- Useful for applications that store session data locally
- Configured in HAProxy using the appsession parameter or cookies

**Sticky Sessions with Cookies - `Example`**

```bash
backend web_servers
    balance roundrobin
    cookie SERVERID insert indirect
    server web1 192.168.1.101:80 cookie web1 check
    server web2 192.168.1.102:80 cookie web2 check
```

- Each client is assigned a cookie, ensuring requests are routed to the same backend server
- Improves session consistency in applications requiring stateful connections

#### Health Checks in HAProxy

- `Purpose:` Verify that backend servers are available before sending traffic.
- `Default Behavior:` Attempts a TCP connection to the server.
- `Automatic Handling:`
  - If a server fails a health check, it is temporarily removed from the backend.
  - Traffic is not sent to unhealthy servers until they pass health checks again.
  - If all backend servers fail, the service becomes unavailable until at least one server recovers.
- `Special Cases:`
  - For some backends (e.g., databases), TCP checks may not fully reflect server health; additional checks may be required.

- `Complementary Tools:`
  - Nginx can be used alongside HAProxy for caching, compression, and static content serving.

**HTTP Health Check Configuration**

```bash
backend web_servers
    option httpchk GET /health
    server web1 192.168.1.101:80 check
    server web2 192.168.1.102:80 check
```

> Sends a GET request to /health to verify the server is functioning.
> Ensures traffic is only sent to healthy servers, improving reliability.

#### High Availability (HA) with HAProxy

- `Problem:` A single load balancer can be a single point of failure, causing downtime or high latency if it fails or is overwhelmed.
- `Solution:` Implement redundancy at every layer, including multiple load balancers and backend servers.
- `Definition:` High Availability ensures that no single component failure causes service downtime.

**Key Points:**

- Use redundant HAProxy servers to prevent a single point of failure.
- Backend servers (web, application, database) should also be redundant.
- Virtual IP (VIP) or failover tools like Keepalived allow automatic failover between load balancers.
- Combined, this setup ensures continuous service availability even if one server fails.

**Typical HA Architecture**

![HA Architecture](/01-servers/06-proxy-rproxy/01-haproxy/img/ha-diagram-animated.gif)

- Clients connect to the Virtual IP, which is served by whichever HAProxy instance is active.
- Backend traffic continues uninterrupted even if one load balancer fails.
