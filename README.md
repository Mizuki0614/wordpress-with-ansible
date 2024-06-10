# Wordpress環境構築

## 環境
- ローカルPC
  - Windows 11
  - VirtualBox 7.0.10
  - Vagrant 2.4.1
- 仮想マシン
  - CentOS 7.2
  - Nginx 1.26.1
  - PHP 8.3.8
  - MySQL 8.0.37
---

## 手順

1. ローカル環境でのCentOS立ち上げ
   1. [ローカルPCセットアップ](./docs/1_vagrant-setting.md)

2. Wordpress導入のためのOS/MW/SW準備
   1. [OSユーザー作成/公開鍵認証設定](./docs/2-1_ssh-setting.md)
   2. [Nginxの導入/設定](./docs/2-2_nginx-setting.md)
   3. [PHPの導入/設定](./docs/2-3_php-setting.md)
   4. [MySQLの導入/設定](./docs/2-4_mysql-setting.md)
   5. [Wordpress導入/設定](./docs/2-5_wordpress-setting.md)