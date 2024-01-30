# I. Service SSH

## 1. Analyse du service

🌞 **S'assurer que le service `sshd` est démarré**

```bash
[bjorn@node1 ~]$ systemctl status
● node1.tp3.b1
    State: running
    Units: 278 loaded (incl. loaded aliases)
     Jobs: 0 queued
   Failed: 0 units
    Since: Mon 2024-01-29 15:08:08 CET; 6min ago
  systemd: 252-13.el9_2
   CGroup: /
           │ ├─sshd.service
           │ │ └─716 "sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups"
```

🌞 **Analyser les processus liés au service SSH**

```bash
[bjorn@node1 ~]$ ps -ef | grep sshd
root         716       1  0 15:08 ?        00:00:00 sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups
root        1402     716  0 15:11 ?        00:00:00 sshd: bjorn [priv]
bjorn       1406    1402  0 15:11 ?        00:00:00 sshd: bjorn@pts/0
bjorn       1457    1407  0 15:38 pts/0    00:00:00 grep --color=auto sshd
```

🌞 **Déterminer le port sur lequel écoute le service SSH**

```bash
[bjorn@node1 ~]$ ss -nlt
State             Recv-Q            Send-Q                       Local Address:Port                         Peer Address:Port            Process
LISTEN            0                 128                                0.0.0.0:22                                0.0.0.0:*
LISTEN            0                 128                                   [::]:22                                   [::]:*
```

🌞 **Consulter les logs du service SSH**

```bash
[bjorn@node1 ~]$ sudo journalctl -r | grep ssh
Jan 29 15:53:05 node1.tp3.b1 sudo[1515]:    bjorn : TTY=pts/0 ; PWD=/home/bjorn ; USER=root ; COMMAND=/bin/journalctl -r sshd
Jan 29 15:53:00 node1.tp3.b1 sudo[1512]:    bjorn : TTY=pts/0 ; 
Jan 29 15:11:50 node1.tp3.b1 sshd[1402]: pam_unix(sshd:session): session opened for user bjorn(uid=1000) by (uid=0)
Jan 29 15:11:49 node1.tp3.b1 sshd[1402]: Accepted password for bjorn from 10.3.1.1 port 60469 ssh2
Jan 29 15:11:46 node1.tp3.b1 sshd[1402]: main: sshd: ssh-rsa algorithm is disabled
Jan 29 15:11:45 node1.tp3.b1 sshd[1366]: pam_unix(sshd:session): session closed for user bjorn
Jan 29 15:11:45 node1.tp3.b1 sshd[1370]: Disconnected from user bjorn 10.3.1.1 port 60466
Jan 29 15:11:45 node1.tp3.b1 sshd[1370]: Received disconnect from 10.3.1.1 port 60466:11: disconnected by user
```

```bash
[bjorn@node1 ~]$ sudo grep sshd /var/log/secure
Oct 23 15:30:03 localhost sshd[811]: Server listening on 0.0.0.0 port 22.
Oct 23 15:30:03 localhost sshd[811]: Server listening on :: port 22.
Jan 29 15:08:20 localhost sshd[716]: Server listening on :: port 22.
Jan 29 15:10:03 localhost sshd[1323]: Accepted password for bjorn from 10.3.1.1 port 60407 ssh2
Jan 29 15:10:03 localhost sshd[1323]: pam_unix(sshd:session): session opened for user bjorn(uid=1000) by (uid=0)
Jan 29 15:11:36 localhost sshd[1337]: Received disconnect from 10.3.1.1 port 60407:11: disconnected by user
Jan 29 15:11:36 localhost sshd[1337]: Disconnected from user bjorn 10.3.1.1 port 60407
Jan 29 15:11:36 localhost sshd[1323]: pam_unix(sshd:session): session closed for user bjorn
Jan 29 15:11:43 localhost sshd[1366]: Accepted password for bjorn from 10.3.1.1 port 60466 ssh2
Jan 29 15:11:43 localhost sshd[1366]: pam_unix(sshd:session): session opened for user bjorn(uid=1000) by (uid=0)
Jan 29 15:11:45 localhost sshd[1370]: Received disconnect from 10.3.1.1 port 60466:11: disconnected by user
Jan 29 15:11:45 localhost sshd[1370]: Disconnected from user bjorn 10.3.1.1 port 60466
```

### 2. Modification du service

🌞 **Identifier le fichier de configuration du serveur SSH**

```bash
[bjorn@node1 ~]$ sudo nano /etc/ssh/sshd_config
```

🌞 **Modifier le fichier de conf**

```bash
[bjorn@node1 ~]$ echo $RANDOM
10091
```

```bash
[bjorn@node1 ~]$ sudo cat /etc/ssh/sshd_config | grep Port
Port 10091
```

- **gérer le firewall**

```bash
[bjorn@node1 ~]$ sudo firewall-cmd --add-port=10091/tcp --permanent
success
[bjorn@node1 ~]$ sudo firewall-cmd --remove-port=22/tcp
Warning: NOT_ENABLED: '22:tcp' not in 'public'
success
```

```bash
[bjorn@node1 ~]$ sudo firewall-cmd --list-all | grep ports
  ports: 10091/tcp
```

🌞 **Redémarrer le service**

```bash
[bjorn@node1 ~]$ sudo systemctl restart sshd
```

🌞 **Effectuer une connexion SSH sur le nouveau port**

```bash
PS C:\Users\fayer> ssh bjorn@10.3.1.11 -p 10091
bjorn@10.3.1.11's password:
Last login: Mon Jan 29 16:18:00 2024 from 10.3.1.1
[bjorn@node1 ~]$
```

✨ **Bonus : affiner la conf du serveur SSH**

```bash
[bjorn@node1 ~]$ sudo cat /etc/ssh/sshd_config
PubkeyAuthentication yes
PasswordAuthentication no
PermitEmptyPasswords no
PermitRootLogin no
```

## II. Service HTTP

### 1. Mise en place

🌞 **Installer le serveur NGINX**

```bash
[bjorn@node1 ~]$ dnf search nginx
Rocky Linux 9 - BaseOS                                                                                                      224 kB/s | 2.2 MB     00:10
Rocky Linux 9 - AppStream                                                                                                   737 kB/s | 7.4 MB     00:10
Rocky Linux 9 - Extras                                                                                                      1.5 kB/s |  14 kB     00:09
```

```bash
[bjorn@node1 ~]$ sudo dnf install nginx
[sudo] password for bjorn:
Rocky Linux 9 - BaseOS                                                                                                      607  B/s | 4.1 kB     00:06
Rocky Linux 9 - BaseOS                                                                                                      223 kB/s | 2.2 MB     00:10
Rocky Linux 9 - AppStream                                                                                                   707  B/s | 4.5 kB     00:06
Rocky Linux 9 - AppStream                                                                                                   705 kB/s | 7.4 MB     00:10
Rocky Linux 9 - Extras                                                                                                      458  B/s | 2.9 kB     00:06
Rocky Linux 9 - Extras                                                                                                      1.4 kB/s |  14 kB     00:09
Dependencies resolved.
Installing: nginx
```

🌞 **Démarrer le service NGINX**

```
[bjorn@node1 ~]$ sudo systemctl start nginx
[sudo] password for bjorn:
[bjorn@node1 ~]$ systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; preset: disabled)
     Active: active (running) since Tue 2024-01-30 13:40:54 CET; 11s ago
```

🌞 **Déterminer sur quel port tourne NGINX**

```bash
[bjorn@node1 ~]$ ss -anlt
State         Recv-Q        Send-Q               Local Address:Port               Peer Address:Port       Process
LISTEN        0             511                        0.0.0.0:80                      0.0.0.0:*
LISTEN        0             511                           [::]:80                         [::]:*
```

```bash
[bjorn@node1 ~]$ sudo firewall-cmd --add-port=80/tcp --permanent
success
[bjorn@node1 ~]$ sudo firewall-cmd --reload
success
```

🌞 **Déterminer les processus liés au service NGINX**

```bash
[bjorn@node1 ~]$ ps -ef | grep nginx
root        1350       1  0 13:40 ?        00:00:00 nginx: master process /usr/sbin/nginx
nginx       1351    1350  0 13:40 ?        00:00:00 nginx: worker process
nginx       1352    1350  0 13:40 ?        00:00:00 nginx: worker process
bjorn       1391    1323  0 13:47 pts/0    00:00:00 grep --color=auto nginx
```

🌞 **Déterminer le nom de l'utilisateur qui lance NGINX**

```bash
[bjorn@node1 ~]$ [bjorn@node1 ~]$  cat /etc/passwd | grep root
root:x:0:0:root:/root:/bin/bash
operator:x:11:0:operator:/root:/sbin/nologin
```

🌞 **Test !**

```bash
fayer@Fello MINGW64 /
$ curl http://10.3.1.11:80 | head -n 7

<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">
```


## 2. Analyser la conf de NGINX

🌞 **Déterminer le path du fichier de configuration de NGINX**

```bash
[bjorn@node1 ~]$ ls -al /etc/nginx/nginx.conf
-rw-r--r--. 1 root root 2334 Oct 16 20:00 /etc/nginx/nginx.conf
```

🌞 **Trouver dans le fichier de conf**

```bash
[bjorn@node1 ~]$ cat /etc/nginx/nginx.conf | grep server -A 5
    server {
        listen       80;
        listen       [::]:80;
        server_name  _;
        root         /usr/share/nginx/html;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html {
        }
```

```bash
[bjorn@node1 ~]$ cat /etc/nginx/nginx.conf | grep include -A 5
include /usr/share/nginx/modules/*.conf;
```

## 3. Déployer un nouveau site web

🌞 **Créer un site web**

```bash
[bjorn@node1 var]$ cd /var/www/
[bjorn@node1 www]$ mkdir tp3_linux
mkdir: cannot create directory ‘tp3_linux’: Permission denied
[bjorn@node1 www]$ sudo !!
sudo mkdir tp3_linux
[bjorn@node1 www]$ cd /var/www/tp3_linux/
[bjorn@node1 tp3_linux]$ sudo nano index.html
[bjorn@node1 tp3_linux]$ cat /var/www/tp3_linux/index.html
<h1>MEOW mon premier serveur web</h1>
```

🌞 **Gérer les permissions**

```bash
[bjorn@node1 tp3_linux]$ sudo chown root /var/www/tp3_linux/
```

🌞 **Adapter la conf NGINX**

```bash
[bjorn@node1 tp3_linux]$ sudo systemctl restart nginx
[bjorn@node1 tp3_linux]$ cat /etc/nginx/default.d/tp3_linux.conf

server {
        listen 24932;
        root /var/www/tp3_linux;
}
[bjorn@node1 tp3_linux]$ sudo systemctl restart nginx
```

```bash
fayer@Fello MINGW64 /
$ curl http://10.3.1.11:24932  2> /dev/null
<h1>MEOW mon premier serveur web</h1>
```

# III. Your own services

🌞 **Afficher le fichier de service SSH**

```bash
[bjorn@node1 ~]$ systemctl status sshd
● sshd.service - OpenSSH server daemon
     Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; preset: enabled)

[bjorn@node1 ~]$ cat /usr/lib/systemd/system/sshd.service | grep ExecStart=
ExecStart=/usr/sbin/sshd -D $OPTIONS
```


🌞 **Afficher le fichier de service NGINX**

```bash
[bjorn@node1 ~]$ systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; preset: disabled)

[bjorn@node1 ~]$ cat /usr/lib/systemd/system/nginx.service | grep ExecStart=
ExecStart=/usr/sbin/nginx
```

## 3. Création de service

🌞 **Créez le fichier `/etc/systemd/system/tp3_nc.service`**

```bash
[bjorn@node1 ~]$ cat /etc/systemd/system/tp3_nc.service
[Unit]
Description=Super netcat tout fou

[Service]
ExecStart=/usr/bin/nc -l 13528 -k
```

🌞 **Indiquer au système qu'on a modifié les fichiers de service**

```bash
[bjorn@node1 ~]$ sudo systemctl daemon-reload
```

🌞 **Démarrer notre service de ouf**

```bash
[bjorn@node1 ~]$ sudo !!
sudo systemctl start tp3_nc
```

🌞 **Vérifier que ça fonctionne**

```bash
[bjorn@node1 ~]$ systemctl status tp3_nc
● tp3_nc.service - Super netcat tout fou
     Loaded: loaded (/etc/systemd/system/tp3_nc.service; static)
     Active: active (running) since Tue 2024-01-30 16:33:10 CET; 1min 0s ago
```

```bash
[bjorn@node1 ~]$ ss -alnt | grep 13
LISTEN 0      10           0.0.0.0:13528      0.0.0.0:*
LISTEN 0      10              [::]:13528         [::]:*
```

```bash
[bjorn@localhost ~]$ nc 10.3.1.11 13528
coucou
```

🌞 **Les logs de votre service**

```bash
[bjorn@node1 ~]$ sudo journalctl -xe -u tp3_nc | grep Started
Jan 30 16:33:10 node1.tp3.b1 systemd[1]: Started Super netcat tout fou.

[bjorn@node1 ~]$ sudo journalctl -xe -u tp3_nc | grep 10.3.1.11
Jan 30 16:38:12 node1.tp3.b1 nc[1876]: Host: 10.3.1.11:13528

[bjorn@node1 ~]$ sudo journalctl -xe -u tp3_nc | grep stop
   Subject: A stop job for unit tp3_nc.service has begun execution
   A stop job for unit tp3_nc.service has begun execution.
   Subject: A stop job for unit tp3_nc.service has finished
   A stop job for unit tp3_nc.service has finished.
```

🌞 **S'amuser à `kill` le processus**

```bash
[bjorn@node1 ~]$ ps -aux | grep nc
root        2017  0.0  0.1  10256  3020 ?        Ss   16:59   0:00 /usr/bin/nc -l 13528 -k
[bjorn@node1 ~]$ sudo !!
sudo kill 2017
```

🌞 **Affiner la définition du service**

```bash
[bjorn@node1 ~]$ cat /etc/systemd/system/tp3_nc.service
[Unit]
Description=Super netcat tout fou

[Service]
ExecStart=/usr/bin/nc -l 13528 -k
Restart=always

[bjorn@node1 ~]$ sudo systemctl restart tp3_nc
[bjorn@node1 ~]$ sudo !!
sudo kill 2107
[bjorn@node1 ~]$ systemctl status tp3_nc
● tp3_nc.service - Super netcat tout fou
     Loaded: loaded (/etc/systemd/system/tp3_nc.service; static)
     Active: active (running) since Tue 2024-01-30 17:17:43 CET; 5s ago
```