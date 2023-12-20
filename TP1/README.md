# TP1 : Casser avant de construire

# II. Casser

## 2. Fichier

🌞 **Supprimer des fichiers**

````bash
[bjorn@localhost ~]$ rm /boot/vmlinuz-5.14.0-284.11.1.el9_2.x86_64
[bjorn@localhost ~]$ rm /boot/vmlinuz-0-rescue-b01d02e8bcee45c897afaf016cbfc3c5
````

## 3. Utilisateurs

🌞 **Mots de passe**

```bash
[bjorn@localhost /]$ sudo awk -F: '/\/home/ && !/nologin/ {print $1}' /etc/passwd | xargs -I {} sudo sh -c 'echo "{}:nouveaumdp" | chpasswd'
```

🌞 **Another way ?**

```bash
[bjorn@localhost ~]$ sudo awk -F: '{print $1}' /etc/passwd | xargs -I {} sudo usermod -L {}
```

## 4. Disques

🌞 **Effacer le contenu du disque dur**

```bash
[bjorn@localhost ~]$ sudo dd if=/dev/zero of=/dev/sda1 bs=4M status=progress
```

## 5. Malware

🌞 **Reboot automatique**

- faites en sorte que si un utilisateur se connecte, ça déclenche un reboot automatique de la machine

## 6. You own way

🌞 **Trouvez 4 autres façons de détuire la machine**

- tout doit être fait depuis le terminal de la machine
- pensez à ce qui constitue un ordi/un OS
- l'idée c'est de supprimer des trucs importants, modifier le comportement de trucs existants, surcharger tel ou tel truc...

![Boom](./img/cat_boom.gif)