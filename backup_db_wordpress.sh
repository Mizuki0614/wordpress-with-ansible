# !/bin/bash

PASSWORD_FILE="/root/.password/mysql_menta_password"
MYSQL_PWD=$(cat $PASSWORD_FILE)
BACKUP_DIR="/var/backups/mysql/wordpress"
DATE=$(date +%Y%m%d)
USER="menta"
DB="wordpress"
BACKUP_FILE="$BACKUP_DIR/wordpress-bk-$DATE.sql"

# Backup取得
mkdir -p $BACKUP_DIR
mysqldump -u $USER -p"$MYSQL_PWD" $DB --single-transaction --no-tablespaces --events > $BACKUP_FILE

# 終了ステータスのチェック
if [ $? -eq 0 ]; then
  echo "Backup successful: $BACKUP_FILE"
else
  echo "Backup failed!"
fi

# Backup世代管理（5世代保持）
cd $BACKUP_DIR
ls -1tr wordpress-bk-*.sql | head -n -5 | xargs -d '\n' rm -f