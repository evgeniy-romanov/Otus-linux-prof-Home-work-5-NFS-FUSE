# Otus_HomeWork_5_NFS_FUSE
## Описание/Пошаговая инструкция выполнения домашнего задания:
NFS:

* vagrant up должен поднимать 2 виртуалки: сервер и клиент;
* на сервер должна быть расшарена директория;
* на клиента она должна автоматически монтироваться при старте (fstab или autofs);
* в шаре должна быть папка upload с правами на запись;
* требования для NFS: NFSv3 по UDP, включенный firewall.

## Выполнение домашнего задания:
1) Требуется предварительно установленный и работоспособный
[Hashicorp Vagrant](https://www.vagrantup.com/downloads) и [Oracle
VirtualBox] (https://www.virtualbox.org/wiki/Linux_Downloads). Также
имеет смысл предварительно загрузить образ CentOS 7 2004.01 из
Vagrant Cloud командой ```vagrant box add centos/7 --provider
virtualbox --box-version 2004.01 --clean```, т.к. предполагается, что
дальнейшие действия будут производиться на таких образах.

2) Создаём тестовые виртуальные машины

    Будем использовать следующий Vagrantfile
```
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "centos/7"

#  config.vm.provision "ansible" do |ansible|
#    ansible.verbose = "vvv"
#    ansible.playbook = "playbook.yml"
#    ansible.become = "true"
#  end

  config.vm.provider "virtualbox" do |v|
    v.memory = 256
    v.cpus = 1
  end

  config.vm.define "nfss" do |nfss|
    nfss.vm.network "private_network", ip: "192.168.50.10", virtualbox__intnet: "net1"
    nfss.vm.hostname = "server"
    nfss.vm.provision "shell", path: "server.sh"
  end

  config.vm.define "nfsc" do |nfsc|
    nfsc.vm.network "private_network", ip: "192.168.50.11", virtualbox__intnet: "net1"
    nfsc.vm.hostname = "client"
    nfsc.vm.provision "shell", path: "client.sh"
  end

end
```
## Создаем скрипты, которые будут устанавливать нужные пакеты и выполнять команды


**"Server.sh"- для серверной машины**

*Установим текстовый редактор NANO*
```
sudo yum -y install nano
```
*Создадим директорию nfs_Share в директории home
и дадим на неё полные права*
```
sudo mkdir -p /home/nfs_Share
sudo chmod -R 777 /home/nfs_Share
```

*В файловом редакторе NANO создадим файл Proverka.txt*
```
sudo touch /home/nfs_Share/Proverka.txt
```

*Остановим Security-Enhanced Linux (SELinux) - это метод контроля доступа в Linux на основе модуля ядра Linux Security (LSM)*
```
sudo setenforce 0
```

*Установим NFS*
```
sudo yum -y install nfs-utils nfs-utils-lib
```

*Включим службы*
```
sudo systemctl enable rpcbind
sudo systemctl enable nfs-server
sudo  systemctl enable nfs-lock
sudo systemctl enable nfs-idmap
sudo systemctl start rpcbind
sudo systemctl start nfs-server
sudo systemctl start nfs-lock
sudo systemctl start nfs-idmap
```
*Добавляем в файл «/etc/exports’ информацию о предоставляемой шаре через NFS и перечитаем его и перезапустим NFS*
```
echo "/home/nfs_Share 192.168.50.0/24(rw,sync,no_root_squash,no_all_squash)" >> /etc/exports
sudo exportfs -a
sudo systemctl restart nfs-server
```

*Стартуем файервол и добавляем (открываем) порты NFS сервера в брандмауэре (firewalld) для корректной работы в сети*
```
sudo systemctl start firewalld.service
sudo systemctl enable firewalld.service
sudo firewall-cmd --permanent --zone=public --add-service=nfs
sudo firewall-cmd --permanent --zone=public --add-service=mountd
sudo firewall-cmd --permanent --zone=public --add-service=rpc-bind
sudo firewall-cmd --reload
```
*Стартуем Security-Enhanced Linux (SELinux) - это метод контроля доступа в Linux на основе модуля ядра Linux Security (LSM)*
```
sudo selinuxenabled 1
```

**"Client.sh"- для клиентской машины**

*Установим текстовый редактор NANO*
```
sudo yum -y install nano
```

*Создаем каталог, куда будем монтировать шару*
```
sudo mkdir -p /mnt/nfs_Open_share
```

*Установим NFS*
```
sudo yum -y install nfs-utils nfs-utils-lib
```

*Включим службы*
```
sudo systemctl enable rpcbind
sudo systemctl enable nfs-server
sudo  systemctl enable nfs-lock
sudo systemctl enable nfs-idmap
sudo systemctl start rpcbind
sudo systemctl start nfs-server
sudo systemctl start nfs-lock
sudo systemctl start nfs-idmap
```

*Смонтируем шару*
```
sudo mount -t nfs 192.168.50.10:/home/nfs_Share/ /mnt/nfs_Open_share/
echo "192.168.50.11:/home/nfs_Share/ /mnt/nfs_Open_share/ nfs rw,sync,hard,intr 0 0"
```
*Стартуем файервол в брандмауэре*
sudo systemctl start firewalld.service
sudo systemctl enable firewalld.service

**После этого запускаем Vagrant**
```
vagrant up
```

*Дожидаемся установки виртуальных машин и отработки скриптов*

*Подключаемся к серверной машине и проверяем начилие файла Proverka.txt*
```
C:\Vagrant\DZ_4>vagrant ssh nfss
[vagrant@Server ~]$ cd /home
[vagrant@Server home]$ ls -al
total 0
drwxr-xr-x.  4 root    root     38 May 26 14:34 .
dr-xr-xr-x. 18 root    root    255 May 26 14:33 ..
drwxrwxrwx.  2 root    root     26 May 26 14:34 nfs_Share
drwx------.  3 vagrant vagrant  74 Apr 30  2020 vagrant
[vagrant@Server home]$ cd nfs_Share
[vagrant@Server nfs_Share]$ ls -al
total 4
drwxrwxrwx. 2 root root 26 May 26 14:34 .
drwxr-xr-x. 4 root root 38 May 26 14:34 ..
-rw-r--r--. 1 root root 15 May 26 14:34 Proverka.txt
```

*Подключаемся к клиентской машине и также проверяем начилие файла Proverka.txt*
```
C:\Vagrant\DZ_4>vagrant ssh nfsc
[vagrant@client ~]$ cd /mnt
[vagrant@client media]$ ls -al
total 0
drwxr-xr-x.  3 root root  28 May 26 14:36 .
dr-xr-xr-x. 18 root root 255 May 26 14:35 ..
drwxrwxrwx.  2 root root  26 May 26 13:41 nfs_Open_share
[vagrant@client media]$ cd nfs_Open_share
[vagrant@client nfs_Open_share]$ ls -al
total 0
drwxrwxrwx. 2 root root 26 May 26 13:41 .
drwxr-xr-x. 3 root root 28 May 26 14:36 ..
-rw-r--r--. 1 root root  0 May 26 13:41 Proverka.txt
```
*Меняем содержание файла Proverka.txt с помощью редактора NANO*
```
[vagrant@client nfs_Open_share]$ sudo nano Proverka.txt
```
*На серверной машине убеждаемся, что изменения в файле прошли*
```
[vagrant@server nfs_Share]$ sudo nano Proverka.txt
```



























 




























