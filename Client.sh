sudo yum -y install nano
sudo mkdir -p /mnt/nfs_Open_share
sudo yum -y install nfs-utils nfs-utils-lib
sudo systemctl enable rpcbind
sudo systemctl enable nfs-server
sudo systemctl enable nfs-lock
sudo systemctl enable nfs-idmap
sudo systemctl start rpcbind
sudo systemctl start nfs-server
sudo systemctl start nfs-lock
sudo systemctl start nfs-idmap
sudo mount -t nfs 192.168.50.10:/home/nfs_Share/ /mnt/nfs_Open_share/
echo "192.168.50.11:/home/nfs_Share/ /mnt/nfs_Open_share/ nfs rw,sync,hard,intr 0 0"
