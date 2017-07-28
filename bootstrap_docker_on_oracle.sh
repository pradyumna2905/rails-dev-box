# The output of all these installation steps is noisy. With this utility
# the progress report is nice and concise.
function install {
    echo installing $1
    shift
    apt-get -y install "$@" >/dev/null 2>&1
}

echo installing OS packages
install Docker docker.io
install Alien alien

echo setting up Oracle database server on Docker
sudo -u vagrant -i git clone -b runs_oracle_enhanced https://github.com/yahonda/docker-images.git \
  /home/vagrant/docker-images
sudo -u vagrant -i cp /vagrant/linuxx64_12201_database.zip \
  /home/vagrant/docker-images/OracleDatabase/dockerfiles/12.2.0.1/.
cd /home/vagrant/docker-images/OracleDatabase/dockerfiles
sudo ./buildDockerImage.sh -v 12.2.0.1 -e
sudo docker run -d -p 1521:1521 -e ORACLE_PWD=admin --name oracle-container oracle/database:12.2.0.1-ee

echo setting up Oracle client
sudo -u vagrant -i cp /vagrant/oracle-instantclient12.2-basic-12.2.0.1.0-1.x86_64.rpm \
  /home/vagrant/.
sudo -u vagrant -i cp /vagrant/oracle-instantclient12.2-devel-12.2.0.1.0-1.x86_64.rpm \
  /home/vagrant/.
sudo -u vagrant -i cp /vagrant/oracle-instantclient12.2-sqlplus-12.2.0.1.0-1.x86_64.rpm \
  /home/vagrant/.

alien -i /home/vagrant/oracle-instantclient12.2-basic-12.2.0.1.0-1.x86_64.rpm
alien -i /home/vagrant/oracle-instantclient12.2-devel-12.2.0.1.0-1.x86_64.rpm
alien -i /home/vagrant/oracle-instantclient12.2-sqlplus-12.2.0.1.0-1.x86_64.rpm

sudo -u vagrant -i echo 'export PATH=/usr/lib/oracle/12.2/client64/bin:$PATH' \
  >> /home/vagrant/.bashrc
sudo -u vagrant -i echo 'export LD_LIBRARY_PATH=/usr/lib/oracle/12.2/client64/lib:$LD_LIBRARY_PATH' \
  >> /home/vagrant/.bashrc
sudo -u vagrant -i echo 'export NLS_LANG=American_America.AL32UTF8' \
  >> /home/vagrant/.bashrc
sudo -u vagrant -i echo 'export DATABASE_NAME=ORCLPDB1' \
  >> /home/vagrant/.bashrc

echo showing Oracle database status. Wait until "DATABASE IS READY TO USE!" message appears.
grep -m 1 "DATABASE IS READY TO USE!" <(sudo docker logs -f oracle-container)

echo 'rails-dev-box runs Oracle on Docker now!'
