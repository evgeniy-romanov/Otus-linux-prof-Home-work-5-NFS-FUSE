sudo yum -y install nano
sudo mkdir -p /home/nfs_Share
sudo chmod -R 777 /home/nfs_Share
sudo touch /home/nfs_Share/Proverka.txt
sudo setenforce 0
sudo yum -y install nfs-utils nfs-utils-lib
sudo systemctl enable rpcbind
sudo systemctl enable nfs-server
sudo  systemctl enable nfs-lock
sudo systemctl enable nfs-idmap
sudo systemctl start rpcbind
sudo systemctl start nfs-server
sudo systemctl start nfs-lock
sudo systemctl start nfs-idmap
echo "/home/nfs_Share 192.168.50.0/24(rw,sync,no_root_squash,no_all_squash)" >> /etc/exports
sudo exportfs -a
sudo systemctl restart nfs-server
sudo systemctl start firewalld.service
sudo systemctl enable firewalld.service
sudo firewall-cmd --permanent --zone=public --add-service=nfs
sudo firewall-cmd --permanent --zone=public --add-service=mountd
sudo firewall-cmd --permanent --zone=public --add-service=rpc-bind
sudo firewall-cmd --reload
sudo selinuxenabled 1

