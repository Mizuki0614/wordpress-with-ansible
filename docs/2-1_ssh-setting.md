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

### OSユーザー作成/公開鍵認証設定

- 参考
    
    [CentOS7.3でSSH接続(公開鍵認証)する方法 - Qiita](https://qiita.com/uhooi/items/137de4578534c8e7e7f2)
    
1. Rootユーザーにスイッチユーザーを行い、Rootユーザーのパスワードを設定します。
    
    ```bash
    su -
    passwd
    ```
    
2. Rootユーザーで新規ユーザーを作成します。当手順ではユーザー`menta` を作成します。
    
    ```bash
    useradd menta
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
        
        ```bash
        ll /vagrant/id_rsa.pub 

        -rwxrwxrwx 1 vagrant vagrant 573 Jun  1 13:06 /vagrant/id_rsa.pub
        ```
        
5. 仮想マシン側でSSHの設定を行います。なお、CentOS 7.2では`openssh-server` がプリインストールされているため、導入は不要です。
    
    ```bash
    vi /etc/ssh/sshd_config
    ```
    
    | 変更前 | 変更後 | 説明 |
    | --- | --- | --- |
    | #PermitRootLogin yes | PermitRootLogin no | rootユーザーによるログインを許可するか |
    | #PasswordAuthentication yes | PasswordAuthentication no | パスワード認証を許可するか |
    | #PermitEmptyPasswords no | PermitEmptyPasswords no | パスワードなしを許可するか |
    |  | Match User vagrant  PasswordAuthentication yes | ユーザーvagrantのみパスワード認証を許可 |
6. SSHサービスを再起動し、OS起動時に起動するように設定します。
    
    ```bash
    systemctl reload sshd.service

    # active (running)と表示されることを確認。
    systemctl status sshd.service
    systemctl enable sshd.service

    # enabledと表示されることを確認。
    systemctl is-enabled sshd.service
    ```
    
7. ローカルPCからアップロードした公開鍵を`~/.ssh/authorized_keys` に登録します。今回はmentaユーザーのログインに対して公開鍵認証を設定したいため、mentaユーザーにスイッチユーザーをしたのち、設定を行います。
    
    ```bash
    su menta
    cd ~
    ls -l .ssh

    # `~/.ssh` フォルダが存在しない場合、作成を行います。
    mkdir ~/.ssh
    chmod 700 ~/.ssh

    # `~/.ssh/authorized_keys` に公開鍵の内容を追記します。
    cat /vagrant/id_rsa.pub >> ~/.ssh/authorized_keys
    chmod 600 ~/.ssh/authorized_keys
    
    # ファイルとディレクトリに対して権限の設定を行います。
    chmod 700 ~/.ssh/
    chmod 600 ~/.ssh/authorized_keys
    rm /vagrant/id_rsa.pub
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

### （補足）LinuxクラアントからのSSH接続の場合
> Linux to Linuxの公開鍵認証では、クライアント側のSSH設定で認証方式を指定する記述を追加する必要があります。  
> 当項目では備忘録として認証方式を設定ファイルに明記しなかった場合に出たエラーとその解決策を記載します。

- **出力エラー**
    ``` bash
    menta@ubuntu-focal:/home/vagrant$ ssh -i /home/menta/.ssh/id_rsa menta@192.168.50.4 -v

    # （略）
    debug1: Next authentication method: publickey
    debug1: Offering public key: /home/menta/.ssh/id_rsa RSA SHA256:MauXntrwjbZj5SJosIoH8qlFgoD9qeNCeidF/bQ0OTU explicit
    debug1: send_pubkey_test: no mutual signature algorithm
    debug1: No more authentication methods to try.
    ```

- **追加対応**
  - /etc/ssh/ssh_config（SSHクライアント側の設定ファイル）に認証方式を指定した（RSA）
    ``` bash
    root@ubuntu-focal:~# vim  /etc/ssh/ssh_config

    +     PubkeyAcceptedKeyTypes ssh-rsa
    ```
