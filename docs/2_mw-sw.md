## Wordpress導入のためのOS/MW/SW準備

### OSユーザー作成/公開鍵認証設定

- 参考
    
    [CentOS7.3でSSH接続(公開鍵認証)する方法 - Qiita](https://qiita.com/uhooi/items/137de4578534c8e7e7f2)
    
1. Rootユーザーにスイッチユーザーを行い、Rootユーザーのパスワードを設定します。
    
    ```powershell
    [vagrant@localhost ~]$ su -
    [root@localhost ~]# passwd
    Changing password for user root.
    New password:
    Retype new password:
    passwd: all authentication tokens updated successfully.
    [root@localhost ~]#
    ```
    
2. Rootユーザーで新規ユーザーを作成します。当手順ではユーザー`menta` を作成します。
    
    ```powershell
    [root@localhost ~]# useradd menta
    ```
    
3. ローカルPCで秘密鍵と公開鍵の作成を行います。以下はPowerShellでのコマンドになります。
    
    ```powershell
    PS C:\Users\waono> ssh-keygen -t rsa -b 4096
    Generating public/private rsa key pair.
    # デフォルトのPATHで問題ない場合はEnterを押下します
    Enter file in which to save the key (C:\Users\{Windowsのユーザー名}\.ssh/id_rsa):
    # パスフレーズの入力を求められるため、2度入力します
    Enter passphrase (empty for no passphrase):
    Enter same passphrase again:
    
    PS C:\Users\waono>
    ```
    
4. 作成した公開鍵を仮想マシンに転送します。公開鍵は作成時に明示的に作成場所を指定していない場合は`C:\Users\{Windowsのユーザー名}\.ssh/id_rsa.pub` に作成されます。Vagrantで起動した仮想マシンへの転送のため、共有ディレクトリを利用して転送を行います。以下はPowerShellでのコマンドになります。
    - Vagrantfileを作成したプロジェクトディレクトリ（自分の環境では`C:\Users\waono\Project\menta`）に移動します。
        
        ```powershell
        	cd C:\Users\waono\Project\menta
        ```
        
    - 作成された公開鍵をプロジェクトディレクトリにコピーします
        
        ```powershell
        cp C:\Users\waono\.ssh\id_rsa.pub .
        ```
        
    - 仮想マシンから`/vagrant` ディレクトリに公開鍵が転送されたことを確認します。
        
        ```powershell
        [menta@localhost ~]$ ll /vagrant/id_rsa.pub 
        -rwxrwxrwx 1 vagrant vagrant 573 Jun  1 13:06 /vagrant/id_rsa.pub
        [menta@localhost ~]$ 
        ```
        
5. 仮想マシン側でSSHの設定を行います。なお、CentOS 7.2では`openssh-server` がプリインストールされているため、導入は不要です。
    
    ```powershell
    [root@localhost ~]# vi /etc/ssh/sshd_config
    ```
    
    | 変更前 | 変更後 | 説明 |
    | --- | --- | --- |
    | #PermitRootLogin yes | PermitRootLogin no | rootユーザーによるログインを許可するか |
    | #PasswordAuthentication yes | PasswordAuthentication no | パスワード認証を許可するか |
    | #PermitEmptyPasswords no | PermitEmptyPasswords no | パスワードなしを許可するか |
    |  | Match User vagrant
      PasswordAuthentication yes | ユーザーvagrantのみパスワード認証を許可 |
6. SSHサービスを再起動し、OS起動時に起動するように設定します。
    
    ```powershell
    [root@localhost ~]# systemctl reload sshd.service
    # active (running)と表示されることを確認。
    [root@localhost ~]# systemctl status sshd.service
    
    [root@localhost ~]# systemctl enable sshd.service
    # enabledと表示されることを確認。
    [root@localhost ~]# systemctl is-enabled sshd.service
    ```
    
7. ローカルPCからアップロードした公開鍵を`~/.ssh/authorized_keys` に登録します。今回はmentaユーザーのログインに対して公開鍵認証を設定したいため、mentaユーザーにスイッチユーザーをしたのち、設定を行います。
    
    ```powershell
    [root@localhost ~]# su menta
    [menta@localhost root]$ cd ~
    [menta@localhost ~]$ ls -l .ssh
    # `~/.ssh` フォルダが存在しない場合、作成を行います。
    [menta@localhost ~]$ mkdir ~/.ssh
    # `~/.ssh/authorized_keys` に公開鍵の内容を追記します。
    [menta@localhost ~]$ cat /vagrant/id_rsa.pub >> ~/.ssh/authorized_keys
    # ファイルとディレクトリに対して権限の設定を行います。
    [menta@localhost ~]$ chmod 700 ~/.ssh/
    [menta@localhost ~]$ chmod 600 ~/.ssh/authorized_keys
    [menta@localhost ~]$ rm /vagrant/id_rsa.pub
    ```
    
8. ローカルPCのSSHクライアントから`ssh` コマンドで仮想マシンに接続ができることを確認します。また、今回の設定ではローカル端末から`dev.menta.me` というホスト名でアクセスしたいため、hostsファイルも併せて修正します。
    - hostsファイル修正
        - 参考
            
            [新規サーバ構築、サーバ移行時に必見！windows10でのhostsファイルの編集方法｜株式会社ネットアシスト](https://www.netassist.ne.jp/techblog/13744/)
            
        - Win + R で`drivers` と入力してEnterを押下します。
        - 開いたエクスプローラーでetc → hostsをクリックし、hostsファイルの場所を確認します。
        - メモ帳を管理者権限で開き「ファイル」→「開く」から、前項で確認したhostsファイルのPATHを入力します。
        - IPアドレスとホスト名の関連付けを追記します。今回は`192.168.50.4` に対して、ホスト名`dev.menta.me` を紐づける形で修正を行います。
            
            ```powershell
            # MENTA
            192.168.50.4    dev.menta.me
            ```
            
        - 保存してメモ帳を閉じます。
    - SSH接続確認
        - PowerShellから`ssh`コマンドを使用してアクセスを試みます。アクセスができることを確認して公開鍵認証の設定は完了です。
            
            ```powershell
            PS C:\Users\waono> ssh -i C:\Users\waono\.ssh\id_rsa menta@dev.menta.me
            Last login: Sun Jun  9 11:05:00 2024
            [menta@localhost ~]$
            ```
            

### Nginxの導入・設定

1. 導入準備
    
    ```bash
    [menta@localhost ~]$ su -
    Password:
    Last login: Sun Jun  9 11:04:53 BST 2024 on pts/1
    [root@localhost ~]# yum update
    # EPELリポジトリの追加
    [root@localhost ~]# yum -y install epel-release
    # remiリポジトリの追加
    [root@localhost ~]# yum install https://rpms.remirepo.net/enterprise/remi-release-7.rpm
    # vim, wgetの導入
    [root@localhost ~]# yum -y install vim, wget
    
    # SELinuxの無効化
    [root@localhost ~]# getenforce
    # Enforcingだった場合に下記を実施
    [root@localhost ~]# vi /etc/selinux/config
    
    SELINUX=disabled
    
    # Nginxリポジトリファイルの作成
    [root@localhost ~]# vi /etc/yum.repos.d/nginx.repo
    
    [nginx-stable]
    name=nginx stable repo
    baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
    gpgcheck=1
    enabled=1
    gpgkey=https://nginx.org/keys/nginx_signing.key
    module_hotfixes=true
    
    [nginx-mainline]
    name=nginx mainline repo
    baseurl=http://nginx.org/packages/mainline/centos/$releasever/$basearch/
    gpgcheck=1
    enabled=0
    gpgkey=https://nginx.org/keys/nginx_signing.key
    module_hotfixes=true
    
    # Nginxインストール
    [root@localhost ~]# yum -y install nginx
    # Nginx起動/OS起動時に起動するように設定
    [root@localhost ~]# systemctl start nginx
    [root@localhost ~]# systemctl enable nginx
    # enabledと表示されることを確認
    [root@localhost ~]# systemctl is-enables nginx
    ```
    
    - ローカルPCのWebブラウザから、仮想マシンのIP（もしくはhostsファイルで設定したホスト名）にアクセスを行い、NginxのWelcomeページが表示されることを確認します。
        
        ![2.jpg](../images/2.jpg)
        
2. Nginx設定変更
    - ドキュメントルートの追加
    - locationの追加
    
    ```bash
    [root@localhost ~]# vim /etc/nginx/nginx.conf
    
        server {
            listen       80;
            listen       [::]:80;
            server_name  _;
            # root         /usr/share/nginx/html;
            # root         /var/www/html;
            # 1. ドキュメントルートを/var/www/dev.menta.meに設定変更
            root         /var/www/dev.menta.me;
    
            # Load configuration files for the default server block.
            include /etc/nginx/default.d/*.conf;
    
            # 2. PHPに対応するようにlocationを追加
            location / {
                    index index.php index.html index.htm;
            }
    
            location ~ \.php$ {
                    fastcgi_pass   unix:/var/run/php-fpm/php-fpm.sock;
                    fastcgi_index  index.php;
                    fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
                    include        fastcgi_params;
            }
    
            error_page 404 /404.html;
            location = /404.html {
            }
    
            error_page 500 502 503 504 /50x.html;
            location = /50x.html {
            }
        }
    ```
    
    - 設定変更後、Nginxプロセスの再起動を行います。
        
        ```bash
        [root@localhost ~]#systemctl restart nginx
        ```
        
3. nginxログの形式変更
    - 参考
        
        - [Nginxで実IPをアクセスログに出力したい場合](https://wiki.adachin.me/archives/1001)
        
        - [【nginx】アクセスログの見方・設定・場所等を解説 | 株式会社ビヨンド | サーバーのことは全部丸投げ](https://beyondjapan.com/blog/2024/02/nginx-access-log/)
        
    - 下記の形式でログ出力を定義します。
        
        ```bash
        [nginx] time:2023-08-06T22:21:55+09:00  server_addr:10.15.0.5   host:216.244.66.233     method:GETreqsize:217     uri:/?p=2802    query:p=2802    status:301      size:5  referer:-       ua:Mozilla/5.0 (compatible; DotBot/1.2; +https://opensiteexplorer.org/dotbot; help@moz.com)       forwardedfor:-    reqtime:0.190   apptime:0.188
        ```
        
    - Nginx設定ファイルの変更
        
        ```bash
        [root@localhost ~]# vim /etc/nginx/nginx.conf
        
        http {
        
        # 1. mainログフォーマットをコメントアウトします。
            # log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
            #                   '$status $body_bytes_sent "$http_referer" '
            #                   '"$http_user_agent" "$http_x_forwarded_for"';
        
        # 2. menta_logログフォーマットを追加します。各変数については参考資料を参照してください。
            log_format  menta_log   '[nginx]\t'
                                    'time:$time_iso8601\t'
                                    'server_addr:$server_addr\t'
                                    'host:$remote_addr\t'
                                    'method:$request_method\t'
                                    'resize:$request_length\t'
                                    'uri:$request_uri\t'
                                    'query:$query_string\t'
                                    'status:$status\t'
                                    'size:$body_bytes_sent\t'
                                    'referer:$http_referer\t'
                                    'ua:$http_user_agent\t'
                                    'forwardedfor:$http_x_forwarded_for\t'
                                    'reqtime:$request_time\t'
                                    'apptime:$upstream_response_time\t';
        
        # 3. access_logのログフォーマット（第二引数）をmainからmenta_logに変更します。
            access_log  /var/log/nginx/access.log  menta_log;
        
        ```
        

### php-fpmの導入/設定

- 参考
    
    [RemiでCentOS7にPHP8をインストールする - Qiita](https://qiita.com/C_HERO/items/1512ba1e33c330c9ab0d)
    
1. Stable最新版php-fpmのインストール
    - 下記ページにアクセスし、OS情報、PHP version、インストールタイプを入力します。画像は、CentOS 7.2でStable最新版のphp-fpmをインストールする際の例です。
        
        [Remi's RPM repository](https://rpms.remirepo.net/wizard/)
        
        ![Untitled](../images/3.png)
        
    - 入力コマンドは上記情報を入力したのち、[**Wizard answer**]に表示されます。手順の概要を下記に記載します。
        
        ```bash
        # yum-utilsのインストール
        yum install yum-utils
        
        # 対象リポジトリの有効化
        yum-config-manager --disable 'remi-php*'
        yum-config-manager --enable   remi-php83
        
        # 有効化されているレポジトリのリストを表示します
        yum repolist
        
        # インストールパッケージの最新化
        yum update -y
        
        # PHPをインストール
        yum install -y php
        
        # PHPのバージョン確認
        php --version
        ```
        
2. php-fpmの設定ファイルをNginxで利用するための設定に修正します。
    
    ```bash
    [root@localhost ~]# vim /etc/php-fpm.d/www.conf
    
    # リスナーを変更
    listen = /var/run/php-fpm/php-fpm.sock
    
    # user、groupをapacheから変更
    user = nginx 
    group = nginx
    
    # listen.owner、listen.groupのコメントアウトを外して値を修正
    listen.owner = nginx
    listen.group = nginx
    ```
    
3. php-fpmを起動して、OS起動時に自動起動するように設定を行います。
    
    ```bash
    [root@localhost ~]# systemctl start php-fpm
    [root@localhost ~]# systemctl enable php-fpm
    # enabledと表示されることを確認
    [root@localhost ~]# systemctl is-enabled php-fpm
    ```
    
4. PHPが使用できることを確認します。
    
    ```bash
    cd /var/www/dev.menta.me/
    echo "<?php echo 'Hello PHP7';" > index.php
    ```
    
    - ローカルPCのWebブラウザから`http://dev.menta.me/index.php` にアクセスを行い、PHPが問題なくブラウザに表示されていることを確認する。
        
        ![Untitled](../images/4.png)