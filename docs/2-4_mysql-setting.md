目次  
1. ローカル環境でのCentOS立ち上げ
   1. [ローカルPCセットアップ](./1_vagrant-setting.md)

2. Wordpress導入のためのOS/MW/SW準備
   1. [OSユーザー作成/公開鍵認証設定](./2-1_ssh-setting.md)
   2. [Nginxの導入/設定](./2-2_nginx-setting.md)
   3. [PHPの導入/設定](./2-3_php-setting.md)
   4. [MySQLの導入/設定](./2-4_mysql-setting.md)
   5. [Wordpress導入/設定](./2-5_wordpress-setting.md)
---

## Wordpress導入のためのOS/MW/SW準備

### MySQLの導入/設定

- 参考
    
    [CentOS7にMySQL公式リポジトリを使って最新のMySQL8.0をインストール｜webツール](http://webadmin.jp/memo/cefa9c749qu1/)
    
1. MariaDBのアンインストール
    
    CentOS 7ではMariaDBが標準でインストールされています。MySQLを利用する場合は競合を起こしてしまうため、MariaDBをアンインストールしたのちMySQLのインストールを行います。
    
    ```bash
    # MariaDB インストール状況確認（以降はインストールされていた場合に実施）
    yum list installed | grep mariadb
    
    # MariaDBのプロセス停止
    systemctl stop mariadb
    
    # MariaDBのアンインストール
    yum remove mariadb-*
    rm -rf /var/lib/mysql/
    ```
    
2. MySQL公式リポジトリから該当OSに対応するバージョンをインストールします。
    
    [MySQL :: Download MySQL Yum Repository](https://dev.mysql.com/downloads/repo/yum/)
    
    ```bash
    # 例
    yum install https://dev.mysql.com/get/mysql84-community-release-el7-1.noarch.rpm
    ```
    
3. MySQL公式リポジトリの無効化
    
    必要なときのみMySQL公式リポジトリを利用するようにデフォルトでの無効化を設定します。
    
    ```bash
    vim /etc/yum.repos.d/mysql-community.repo
    
    # すべてのリポジトリについて
    enabled=1
    ↓
    enabled=0
    ```
    
4. MySQL8.0をインストールします。
    
    ```bash
    yum --enablerepo=mysql80-community install mysql-community-server
    
    # MySQL バージョン確認
    mysqld --version
    mysql  Ver 8.0.37 for Linux on x86_64 (MySQL Community Server - GPL)
    ```
    
5. OS起動時にMySQLが起動してくるように設定します。
    
    ```bash
    systemctl start mysqld.service
    systemctl enable mysqld.service

    # enabledと表示されることを確認
    systemctl is-enabled mysqld.service
    ```
    
6. 初期パスワードの確認を行います。
`/var/log/mysqld.log` にrootの初期パスワードが記載されているので、下記コマンドを実行し、設定を控えます。
    
    ```bash
    grep password /var/log/mysqld.log
    
    9999-99-99T09:09:09.999999Z 9 [Note] [MY-010454] [Server] A temporary password is generated for root@localhost:xxxxxxxxxxxxxx
    ```
    
1. `mysql_secure_installation`を使用して対話形式で初期設定を行います。
    
    ```bash
    mysql_secure_installation
    ```
    
    ```bash
    # 以下を参考に、対話形式での設定を行う
    Securing the MySQL server deployment.
    
    Enter password for user root: [初期パスワードを入力][Enter]
    
    The existing password for the user account root has expired. Please set a new password.
    
    New password: [新しいパスワードを入力][Enter]
    
    Re-enter new password: [再度、新しいパスワードを入力][Enter]
    The 'validate_password' component is installed on the server.
    The subsequent steps will run with the existing configuration
    of the component.
    Using existing password for root.
    
    Estimated strength of the password: 100
    Change the password for root ? ((Press y|Y for Yes, any other key for No) : [yを入力][Enter]
    
    New password: [新しいパスワードを入力][Enter]
    
    Re-enter new password: [再度、新しいパスワードを入力][Enter]
    
    Estimated strength of the password: 100
    Do you wish to continue with the password provided?(Press y|Y for Yes, any other key for No) : [yを入力][Enter]
    By default, a MySQL installation has an anonymous user,
    allowing anyone to log into MySQL without having to have
    a user account created for them. This is intended only for
    testing, and to make the installation go a bit smoother.
    You should remove them before moving into a production
    environment.
    
    Remove anonymous users? (Press y|Y for Yes, any other key for No) : [yを入力][Enter]
    Success.
    
    Normally, root should only be allowed to connect from
    'localhost'. This ensures that someone cannot guess at
    the root password from the network.
    
    Disallow root login remotely? (Press y|Y for Yes, any other key for No) : [yを入力][Enter]
    Success.
    
    By default, MySQL comes with a database named 'test' that
    anyone can access. This is also intended only for testing,
    and should be removed before moving into a production
    environment.
    
    Remove test database and access to it? (Press y|Y for Yes, any other key for No) : [yを入力][Enter]
     - Dropping test database...
    Success.
    
     - Removing privileges on test database...
    Success.
    
    Reloading the privilege tables will ensure that all changes
    made so far will take effect immediately.
    
    Reload privilege tables now? (Press y|Y for Yes, any other key for No) : [yを入力][Enter]
    Success.
    
    All done!
    ```
    
2. /etc/my.cnfの設定変更を行います。
    
    ```bash
    # /vagrant にバックを取得
    cp -p /etc/my.cnf /vagrant/bk_config/
    
    vim /etc/my.cnf
    ```

    ```bash
    # /etc/my.cnf

    [mysqld]
    user = mysql
    port = 3306
    
    socket = /var/lib/mysql/mysql.sock
    pid-file = /var/run/mysqld/mysqld.pid
    default_authentication_plugin = mysql_native_password
    default_password_lifetime = 0
    datadir = /var/lib/mysql
    log-error = /var/log/mysql/mysql.log
    binlog_expire_logs_seconds = 864000 #10days
    
    ### utf8mb4
    character_set_server = utf8mb4
    collation_server = utf8mb4_bin
    init_connect = 'SET NAMES utf8mb4'
    skip-character-set-client-handshake
    
    skip-name-resolve
    #symbolic-links = 0
    default-storage-engine = innodb
    #sql_mode = ''
    explicit_defaults_for_timestamp = true
    
    wait_timeout = 300
    max_connections = 100
    table_open_cache = 1000
    table_definition_cache = 500
    open_files_limit = 1400
    
    max_allowed_packet = 16M
    
    slow_query_log = 1
    slow_query_log_file = /var/log/mysql/slow.log
    long_query_time = 2.0
    min_examined_row_limit = 1000
    log-queries-not-using-indexes
    
    [mysql.server]
    #default-character-set = utf8
    default-character-set = utf8mb4
    
    [mysqld_safe]
    #default-character-set = utf8
    default-character-set = utf8mb4
    
    [mysql]
    #default-character-set = utf8
    default-character-set = utf8mb4
    
    [client]
    #default-character-set = utf8
    default-character-set = utf8mb4
    
    [mysqldump]
    #default-character-set = utf8
    default-character-set = utf8mb4
    ```
    
3. /etc/my.cnfにて変更したログ出力先のディレクトリを作成します。併せて、MySQLの再起動を実施します。
    
    ```bash
    mkdir /var/log/mysql
    chown -R mysql:mysql /var/log/mysql
    
    # MySQLの再起動を実施
    systemctl restart mysqld.service
    ```
    
4.  wordpress データベースを作成します。
    
    ```bash
    mysql -u root -p
    Enter password: [PASSWORD]
    
    # データベース wordpressを作成
    mysql> create database if not exists wordpress;
    Query OK, 1 row affected (0.04 sec)
    
    # データベース一覧を確認
    mysql> show databases;
    +--------------------+
    | Database           |
    +--------------------+
    | information_schema |
    | mysql              |
    | performance_schema |
    | sys                |
    | wordpress          |
    +--------------------+
    5 rows in set (0.02 sec)
    ```
    
5.  ユーザー mentaを作成して、データベース wordpressへの権限を付与します。
    
    ```bash
    mysql> create user menta@localhost identified by 'PASSWORD';
    Query OK, 0 rows affected (0.02 sec)
    
    mysql> grant all on wordpress.* to menta@localhost;
    Query OK, 0 rows affected, 1 warning (0.01 sec)
    
    # ユーザーの確認
    mysql> SELECT user, host FROM mysql.user;
    +------------------+-----------+
    | user             | host      |
    +------------------+-----------+
    | menta            | localhost |
    | mysql.infoschema | localhost |
    | mysql.session    | localhost |
    | mysql.sys        | localhost |
    | root             | localhost |
    +------------------+-----------+
    5 rows in set (0.00 sec)
    
    # ユーザー mentaの権限確認
    mysql> SHOW GRANTS FOR 'menta'@'localhost';
    +--------------------------------------------------------------+
    | Grants for menta@localhost                                   |
    +--------------------------------------------------------------+
    | GRANT USAGE ON *.* TO `menta`@`localhost`                    |
    | GRANT ALL PRIVILEGES ON `wordpress`.* TO `menta`@`localhost` |
    +--------------------------------------------------------------+
    2 rows in set (0.00 sec)
    ```