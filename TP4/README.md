# Partie 1 : Partitionnement du serveur de stockage

🌞 **Partitionner le disque à l'aide de LVM**

```bash
[bjorn@storage ~]$ sudo pvcreate /dev/sdb
[sudo] password for bjorn:
  Physical volume "/dev/sdb" successfully created.
[bjorn@storage ~]$ sudo pvcreate /dev/sdc
  Physical volume "/dev/sdc" successfully created.
  ```

```bash
[bjorn@storage ~]$ sudo vgcreate storage /dev/sdb
  Volume group "storage" successfully created
[bjorn@storage ~]$ sudo vgextend storage /dev/sdc
  Volume group "storage" successfully extended
```

```bash
[bjorn@storage ~]$ sudo lvcreate -l +100%FREE storage -n PartitionStorage
  Logical volume "PartitionStorage" created.
```

🌞 **Formater la partition**

```bash
[bjorn@storage ~]$ sudo !!
sudo mkfs -t ext4 /dev/storage/PartitionStorage
mke2fs 1.46.5 (30-Dec-2021)
Creating filesystem with 1046528 4k blocks and 261632 inodes
Filesystem UUID: 209d69ac-3588-4227-aa2c-3ef95b5ea07e
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912, 819200, 884736

Allocating group tables: done
Writing inode tables: done
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done
```

🌞 **Monter la partition**

```bash
[bjorn@storage ~]$ sudo !!
sudo mount /dev/storage/PartitionStorage /storage/
[bjorn@storage ~]$ df -h | grep /storage
/dev/mapper/storage-PartitionStorage  3.9G  8.0K  3.7G   1% /storage
[bjorn@storage ~]$ cat /etc/fstab | grep storage
/dev/storage/PartitionStorage   /storage        ext4    defaults        0 0
[bjorn@storage ~]$ sudo umount /storage
[sudo] password for bjorn:
[bjorn@storage ~]$ sudo mount -av
mount: (hint) your fstab has been modified, but systemd still uses
/boot                    : successfully mounted
/storage                 : successfully mounted
[bjorn@storage ~]$ sudo reboot
```

⭐**BONUS**

- utilisez une commande `dd` pour remplir complètement la nouvelle partition
- prouvez que la partition est remplie avec une commande `df`
- ajoutez un nouveau disque dur de 2G à la machine
- ajoutez ce new disque dur à la conf LVM
- agrandissez la partition pleine à l'aide du nouveau disque
- prouvez aavec un `df` que la partition a bien été agrandie

# Partie 2 : Serveur de partage de fichiers

🌞 **Donnez les commandes réalisées sur le serveur NFS `storage.tp4.linux`**

```bash
[bjorn@storage ~]$ sudo mkdir /storage/site_web_1
[sudo] password for bjorn:
[bjorn@storage ~]$ mkdir /storage/site_web_2
mkdir: cannot create directory ‘/storage/site_web_2’: Permission denied
[bjorn@storage ~]$ sudo !!
sudo mkdir /storage/site_web_2
[bjorn@storage ~]$ cd /storage/
[bjorn@storage storage]$ ls
site_web_1  site_web_2
[bjorn@storage storage]$ cd
[bjorn@storage ~]$ sudo chown nobody /storage/site_web_1/
[bjorn@storage ~]$ sudo chown nobody /storage/site_web_2/
[bjorn@storage ~]$ sudo nano /etc/exports
[bjorn@storage ~]$ sudo systemctl enable nfs-server
Created symlink /etc/systemd/system/multi-user.target.wants/nfs-server.service → /usr/lib/systemd/system/nfs-server.service.
[bjorn@storage ~]$ sudo systemctl start nfs-server
[bjorn@storage ~]$ sudo systemctl status nfs-server
● nfs-server.service - NFS server and services
     Loaded: loaded (/usr/lib/systemd/system/nfs-server.service; enabled; preset: disabled)
    Drop-In: /run/systemd/generator/nfs-server.service.d
             └─order-with-mounts.conf
     Active: active (exited) since Tue 2024-02-20 14:45:15 CET; 7s ago
    Process: 14912 ExecStartPre=/usr/sbin/exportfs -r (code=exited, status=0/SUCCESS)
    Process: 14913 ExecStart=/usr/sbin/rpc.nfsd (code=exited, status=0/SUCCESS)
    Process: 14934 ExecStart=/bin/sh -c if systemctl -q is-active gssproxy; then systemctl reload gssproxy ; fi (code=exited, status=0/SUCCESS)
   Main PID: 14934 (code=exited, status=0/SUCCESS)
        CPU: 52ms
[bjorn@storage ~]$ sudo !!
sudo firewall-cmd --permanent --list-all | grep services
  services: cockpit dhcpv6-client ssh
[bjorn@storage ~]$ sudo !!
sudo firewall-cmd --permanent --add-service=nfs
success
[bjorn@storage ~]$ sudo firewall-cmd --permanent --add-service=mountd
success
[bjorn@storage ~]$ sudo firewall-cmd --permanent --add-service=rpc-bind
success
[bjorn@storage ~]$ sudo !!
sudo firewall-cmd --reload
success
[bjorn@storage ~]$ sudo !!
sudo firewall-cmd --permanent --list-all | grep services
  services: cockpit dhcpv6-client mountd nfs rpc-bind ssh
```

```bash
[bjorn@web ~]$ cat /etc/fstab

/dev/mapper/rl-root     /                       xfs     defaults        0 0
UUID=870a5d22-b226-4fb4-8d96-a67e971b29d5 /boot                   xfs     defaults        0 0
/dev/mapper/rl-swap     none                    swap    defaults        0 0
```

🌞 **Donnez les commandes réalisées sur le client NFS `web.tp4.linux`**

```bash
[bjorn@web ~]$ sudo mkdir /var/www/site_web_1
[sudo] password for bjorn:
mkdir: cannot create directory ‘/var/www/site_web_1’: No such file or directory
[bjorn@web ~]$ sudo mkdir /var/www/site_web_1 -p
[bjorn@web ~]$ sudo mkdir /var/www/site_web_2 -p
[bjorn@web ~]$ sudo mount 10.3.1.11:/storage/site_web_1 /var/www/site_web_1
[sudo] password for bjorn:
[bjorn@web ~]$ sudo mount 10.3.1.11:/storage/site_web_2 /var/www/site_web_2
[bjorn@web ~]$ df -h | grep storage
10.3.1.11:/storage/site_web_1  3.9G     0  3.7G   0% /var/www/site_web_1
10.3.1.11:/storage/site_web_2  3.9G     0  3.7G   0% /var/www/site_web_2
```

```bash
[bjorn@storage ~]$ cat /etc/exports
/storage/site_web_1     10.3.1.12(rw,sync,no_subtree_check)
/storage/site_web_2     10.3.1.12(rw,sync,no_subtree_check)
```

# Partie 3 : Serveur web

### 2. Install

🌞 **Installez NGINX**

```bash
[bjorn@web ~]$ sudo systemctl enable nginx
Created symlink /etc/systemd/system/multi-user.target.wants/nginx.service → /usr/lib/systemd/system/nginx.service.
[bjorn@web ~]$ sudo systemctl start nginx
[bjorn@web ~]$ sudo firewall-cmd --permanent --add-service=http
success
[bjorn@web ~]$ sudo firewall-cmd --reload
success
[bjorn@web ~]$ systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; preset: disabled)
     Active: active (running) since Tue 2024-02-20 16:04:10 CET; 1min 10s ago
```

🌞 **Analysez le service NGINX**

```bash
[bjorn@web ~]$ ps aux | grep nginx
nginx        835  0.0  0.1  13908  4980 ?        S    22:07   0:00 nginx: worker process
LISTEN            0                 511                                   [::]:80                                   [::]:*
LISTEN            0                 511                                0.0.0.0:80                                0.0.0.0:*

[bjorn@web ~]$ sudo cat /etc/nginx/nginx.conf | grep root
[sudo] password for bjorn:
        root         /usr/share/nginx/html;
```

## 4. Visite du service web

🌞 **Configurez le firewall pour autoriser le trafic vers le service NGINX**

```bash
[bjorn@web ~]$ sudo firewall-cmd --add-port=80/tcp --permanent
success
[bjorn@web ~]$ sudo firewall-cmd --reload
success
```

🌞 **Accéder au site web**

```bash
[bjorn@web ~]$ curl 10.3.1.12
<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
```

🌞 **Vérifier les logs d'accès**

```bash
[bjorn@web ~]$ tail -3 /var/log/nginx/access.log
10.3.1.1 - - [24/Feb/2024:22:16:32 +0100] "GET /icons/poweredby.png HTTP/1.1" 200 15443 "http://10.3.1.12/" "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:123.0) Gecko/20100101 Firefox/123.0" "-"
10.3.1.1 - - [24/Feb/2024:22:16:32 +0100] "GET /poweredby.png HTTP/1.1" 200 368 "http://10.3.1.12/" "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:123.0) Gecko/20100101 Firefox/123.0" "-"
10.3.1.12 - - [24/Feb/2024:22:16:56 +0100] "GET / HTTP/1.1" 200 7620 "-" "curl/7.76.1" "-"
```

## 5. Modif de la conf du serveur web

🌞 **Changer le port d'écoute**

```bash
[bjorn@web ~]$ sudo cat /etc/nginx/nginx.conf | grep listen
        listen       8080;
[bjorn@web ~]$ sudo systemctl restart nginx
[bjorn@web ~]$ sudo systemctl status nginx
     Active: active (running) since Sat 2024-02-24 22:23:56 CET; 23s ago
[bjorn@web ~]$ ss -ltn | grep 8080
LISTEN 0      511          0.0.0.0:8080      0.0.0.0:*
[bjorn@web ~]$ curl 10.3.1.12:8080
<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
```

🌞 **Changer l'utilisateur qui lance le service**

```bash
[bjorn@web ~]$ sudo !!
sudo useradd web
[bjorn@web ~]$ sudo passwd web
Changing password for user web.
[bjorn@web ~]$ sudo cat /etc/nginx/nginx.conf | grep user
user web;
[bjorn@web ~]$ sudo systemctl restart nginx
[bjorn@web ~]$ ps aux | grep web
web         1521  0.0  0.1  13908  4976 ?        S    22:41   0:00 nginx: worker process
web         1522  0.0  0.1  13908  4976 ?        S    22:41   0:00 nginx: worker process
```

🌞 **Changer l'emplacement de la racine Web**

```bash
[bjorn@web ~]$ cat /var/www/site_web_1/index.html
<h1>Meow le chat</h1>
[bjorn@web ~]$ sudo cat /etc/nginx/nginx.conf | grep root
        root         /var/www/site_web_1/;
[bjorn@web ~]$ curl 10.3.1.12:8080
<h1>Meow le chat</h1>
```

## 6. Deux sites web sur un seul serveur

🌞 **Repérez dans le fichier de conf**

```bash
[bjorn@web ~]$ sudo cat /etc/nginx/nginx.conf | grep etc/nginx/conf
    # Load modular configuration files from the /etc/nginx/conf.d directory.
    include /etc/nginx/conf.d/*.conf;
```

🌞 **Créez le fichier de configuration pour le premier site**

```bash
[bjorn@web ~]$ sudo cat /etc/nginx/conf.d/site_web_1.conf
server {
        listen       8080;
        listen       [::]:80;
        server_name  nginx;
        root         /var/www/site_web_1/;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }
```

🌞 **Créez le fichier de configuration pour le deuxième site**

```bash
[bjorn@web ~]$ sudo cat /etc/nginx/conf.d/site_web_2.conf
server {
        listen       8888;
        listen       [::]:80;
        server_name  nginx;
        root         /var/www/site_web_2/;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }
```

```bash
[bjorn@web ~]$ sudo firewall-cmd --add-port=8888/tcp --permanent
success
[bjorn@web ~]$ sudo firewall-cmd --reload
success
```

🌞 **Prouvez que les deux sites sont disponibles**

```bash
PS C:\Users\fayer> curl 10.3.1.12:8080

StatusCode        : 200
StatusDescription : OK
Content           : <h1>Meow le chat</h1>
```

```bash
PS C:\Users\fayer> curl 10.3.1.12:8888

StatusCode        : 200
StatusDescription : OK
Content           : <h1>Meow le deuxiÃ¨me chat</h1>
```
