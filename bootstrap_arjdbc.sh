# The output of all these installation steps is noisy. With this utility
# the progress report is nice and concise.
function install {
    echo installing $1
    shift
    apt-get -y install "$@" >/dev/null 2>&1
}

echo installing OS packages
install OpenJDK openjdk-8-jdk
install Ant ant

echo setting up rbenv
sudo -u ubuntu -i git clone https://github.com/rbenv/rbenv.git /home/ubuntu/.rbenv
sudo -u ubuntu -i echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> /home/ubuntu/.bashrc
sudo -u ubuntu -i echo 'eval "$(rbenv init -)"' >> /home/ubuntu/.bashrc
sudo -u ubuntu -i git clone https://github.com/sstephenson/ruby-build.git /home/ubuntu/.rbenv/plugins/ruby-build

echo installing JRuby
sudo -H -u ubuntu bash -i -c 'source  /home/ubuntu/.bashrc'
sudo -H -u ubuntu bash -i -c 'rbenv install jruby-9.1.5.0'
sudo -H -u ubuntu bash -i -c 'rbenv global jruby-9.1.5.0'
sudo -H -u ubuntu bash -i -c 'gem install bundle'

echo setting up PostgreSQL
sudo -u ubuntu -i echo 'export PGHOST=localhost' >> /home/ubuntu/.bashrc
rm /etc/postgresql/9.5/main/pg_hba.conf
echo 'local all all trust' >> /etc/postgresql/9.5/main/pg_hba.conf
echo 'host all all 127.0.0.1/32 trust' >> /etc/postgresql/9.5/main/pg_hba.conf
echo 'host all all ::1/128 trust' >> /etc/postgresql/9.5/main/pg_hba.conf
service postgresql restart
echo "create user rails superuser;" | sudo -u postgres psql

echo setting up MySQL
mysql -uroot -proot <<SQL
set password = '';
SQL
echo 'rails-dev-box runs JRuby now!'
