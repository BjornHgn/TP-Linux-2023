# Partie : Files and users

## I. Fichiers

### 1. Find me

🌞 **Trouver le chemin vers le répertoire personnel de votre utilisateur**

```/home/bjorn```

🌞 **Trouver le chemin du fichier de logs SSH**

```/var/log/secure```

🌞 **Trouver le chemin du fichier de configuration du serveur SSH**

```/etc/ssh/sshd_config```

## II. Users

### 1. Nouveau user

🌞 **Créer un nouvel utilisateur**


```bash
[bjorn@localhost ~]$ sudo useradd -d /home/papier_alu/ -m marmotte
[bjorn@localhost ~]$ sudo passwd marmotte
```

### 2. Infos enregistrées par le système

🌞 **Prouver que cet utilisateur a été créé**

```bash
[bjorn@localhost ~]$ cat /etc/passwd | grep marmotte
marmotte:x:1001:1001::/home/papier_alu/:/bin/bash
```

🌞 **Déterminer le *hash* du password de l'utilisateur `marmotte`**

```bash
[bjorn@localhost ~]$ sudo cat /etc/shadow | grep marmotte
[sudo] password for bjorn:
marmotte:$6$9HOZ9lF2c4G3YUXK$f8drmsDFH5DduuUMnnOmaPb5n.AHmwSfqVz0Tdk2DKBDN7LabZjq4.7giDV7pc3aKy4fZ70.obHEU9G33Qd/.1:19744:0:99999:7:::
```

### 3. Connexion sur le nouvel utilisateur

🌞 **Tapez une commande pour vous déconnecter : fermer votre session utilisateur**

```exit```

🌞 **Assurez-vous que vous pouvez vous connecter en tant que l'utilisateur `marmotte`**

```bash
PS C:\Users\fayer> ssh marmotte@10.7.1.5
marmotte@10.7.1.5's password:
[marmotte@localhost]$
```

```bash
[marmotte@localhost home]$ cd bjorn
-bash: cd: bjorn: Permission denied
```

# Partie 2 : Programmes et paquets

## I. Programmes et processus

### 1. Run then kill

🌞 **Lancer un processus `sleep`**

```bash
[bjorn@localhost ~]$ sleep 1000
[bjorn@localhost ~]$ ps -h | grep sleep
   1440 pts/1    S+     0:00 sleep 1000
```

🌞 **Terminez le processus `sleep` depuis le deuxième terminal**

```[bjorn@localhost ~]$ kill 1440```


### 2. Tâche de fond

🌞 **Lancer un nouveau processus `sleep`, mais en tâche de fond**

```bash
[bjorn@localhost ~]$ sleep 1000 &
[1] 1459
```

🌞 **Visualisez la commande en tâche de fond**

```bash
[bjorn@localhost ~]$ ps -e
1459 pts/1    00:00:00 sleep
```

### 3. Find paths

🌞 **Trouver le chemin où est stocké le programme `sleep`**

```bash
[bjorn@localhost ~]$ which sleep
/usr/bin/sleep
```

🌞 Tant qu'on est à chercher des chemins : **trouver les chemins vers tous les fichiers qui s'appellent `.bashrc`**

```bash
[bjorn@localhost ~]$ sudo find / -name .bashrc
/etc/skel/.bashrc
/root/.bashrc
/home/bjorn/.bashrc
/home/marmotte/.bashrc
```

### 4. La variable PATH


🌞 **Vérifier que**

```bash
[bjorn@localhost ~]$ echo $PATH
/home/bjorn/.local/bin:/home/bjorn/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin
[bjorn@localhost ~]$ which sleep
/usr/bin/sleep
[bjorn@localhost ~]$ which ssh
/usr/bin/ssh
[bjorn@localhost ~]$ which ping
/usr/bin/ping
```

## II. Paquets

🌞 **Installer le paquet `firefox`**

```bash
[bjorn@localhost ~]$ sudo dnf install git
Total download size: 14 M
Installed size: 61 M
Is this ok [y/N]: y
Complete!
```

🌞 **Utiliser une commande pour lancer Firefox**

```bash
[bjorn@localhost ~]$ which git
/usr/bin/git`
```

🌞 **Installer le paquet `nginx`**

```bash
[bjorn@localhost ~]$ sudo dnf install nginx
Installing:
 nginx                                    x86_64                        1:1.20.1-14.el9_2.1                          appstream                         36 k
```

🌞 **Déterminer**

```bash
[bjorn@localhost ~]$ sudo find / -name nginx
/var/log/nginx
[bjorn@localhost ~]$ sudo find / -name nginx.conf
/etc/nginx/nginx.conf
```

🌞 **Mais aussi déterminer...**

```bash
[bjorn@localhost ~]$ cd /etc/yum.repos.d/
[bjorn@localhost yum.repos.d]$ grep -nr -E '^mirrorlist'
rocky-addons.repo:13:mirrorlist=https://mirrors.rockylinux.org/mirrorlist?arch=$basearch&repo=HighAvailability-$releasever$rltype
rocky-addons.repo:23:mirrorlist=https://mirrors.rockylinux.org/mirrorlist?arch=$basearch&repo=HighAvailability-$releasever-debug$rltype
rocky-addons.repo:32:mirrorlist=https://mirrors.rockylinux.org/mirrorlist?arch=source&repo=HighAvailability-$releasever-source$rltype
rocky-addons.repo:41:mirrorlist=https://mirrors.rockylinux.org/mirrorlist?arch=$basearch&repo=ResilientStorage-$releasever$rltype
rocky-addons.repo:51:mirrorlist=https://mirrors.rockylinux.org/mirrorlist?arch=$basearch&repo=ResilientStorage-$releasever-debug$rltype
```
# Partie 3 : Poupée russe


🌞 **Récupérer le fichier `meow`**

```bash
[bjorn@localhost ~]$ wget -O /home/bjorn/meow https://gitlab.com/it4lik/b1-linux-2023/-/blob/master/tp/2/meow
```

🌞 **Trouver le dossier `dawa/`**

```bash
[bjorn@localhost ~]$ file meow
meow: XZ compressed data
[bjorn@localhost ~]$ xz -d -f meow.xz
...
[bjorn@localhost ~]$ ls
dawa  meow.rar  meow.tar.gz  meow.zip
```

🌞 **Dans le dossier `dawa/`, déterminer le chemin vers**


