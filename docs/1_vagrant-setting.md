目次  
1. ローカル環境でのCentOS立ち上げ
   1. [ローカルPCセットアップ](./docs/1_vagrant-setting.md)

2. Wordpress導入のためのOS/MW/SW準備
   1. [OSユーザー作成/公開鍵認証設定](./docs/2-1_ssh-setting.md)
   2. [Nginxの導入/設定](./docs/2-2_nginx-setting.md)
   3. [PHPの導入/設定](./docs/2-3_php-setting.md)
   4. [MySQLの導入/設定](./docs/2-4_mysql-setting.md)
   5. [Wordpress導入/設定](./docs/2-5_wordpress-setting.md)
---

## ローカル環境でのCentOS立ち上げ

### VagrantとVirtualBoxのインストール

以下のページからVagrantとVirtualBoxをインストールします

- Vagrant
    
    [Install | Vagrant | HashiCorp Developer](https://developer.hashicorp.com/vagrant/install?product_intent=vagrant)
    
- VirtualBox
    
    [Downloads     – Oracle VM VirtualBox](https://www.virtualbox.org/wiki/Downloads)
    

### VagrantでCentOS 7.2を立ち上げる

1. 下記ページにアクセスして立ち上げるBoxを選択します。今回はCentOS 7.2を選択します。
    ![1](../images/1.png)

    [A list of base boxes for Vagrant - Vagrantbox.es](https://www.vagrantbox.es/)
    
    
2. PowerShellからvagrantコマンドを使ってBoxを追加します。Box名はcentos72とします。
    
    ```bash
    vagrant add box centos72 {コピーしたURL}
    ```
    
3. Windowsの適当な場所にプロジェクトディレクトリを作成します。当手順では`C:\Users\waono\Project\menta` としています。PowerShellで作成したディレクトリに移動し、Vagrantfileを作成します。
    
    ```bash
    cd C:\Users\waono\Project\menta
    vagrant init centos72
    ```
    
4. 作成されたVagrantfileを修正します。
    - Private IPの設定（`192.168.50.4`とする）
    - 割り当てメモリーの設定（2048MBとする）
    - 仮想マシン起動時の起動コマンド設定
    - ローカルPCと仮想マシン間の共有ディレクトリ設定
        
        ```bash
        config.vm.network "private_network", ip: "192.168.50.4"
        
        # 既に定義が存在する場合は値を修正
        vb.memory = "2048"
        
        config.vm.provision "shell", run: "always", inline: "systemctl restart network.service"
        
        config.vm.synced_folder "./", "/var/www/html/", owner: 'vagrant', group: 'vagrant'
        ```
        
5. Vagrantfileが作成されたディレクトリで下記コマンドを実行して仮想環境を起動します。
    
    ```bash
    vagrant up
    ```
    
6. ローカルPCからSSHで、起動した仮想環境にログインを行います。PowerShellやTeratermなどのSSHクライアントから実施してください。以下はPowerShellからSSHでアクセスを行う例です。
    
    ```powershell
    PS C:\Users\waono> ssh vagrant@192.168.50.4
    vagrant@192.168.50.4's password:{vagrant}
    ```
    
7. 仮想OSにログインができたらyumのアップデートを行います。
    
    ```powershell
    sudo yum update
    ```

- 参考
   [Windows+VagrantでCentOS7.2の仮想環境を構築する](http://program-memo.com/archives/467)
