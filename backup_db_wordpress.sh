# !/bin/bash
set -eu

PASSWORD_SH="/root/.password/mysql_menta_password.sh"
MYSQL_PWD=$(source $PASSWORD_SH)
BACKUP_DIR="/var/backups/mysql/wordpress"
DATE=$(date +%Y%m%d)
USER="menta"
DB="wordpress"
BACKUP_FILE="$BACKUP_DIR/wordpress-bk-$DATE.sql"

OLD_DATE=$(date +%Y%m%d --date "5 days ago")
OLD_BACKUP_FILE="$BACKUP_DIR/wordpress-bk-$OLD_DATE.sql"

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
rm -f ${OLD_BACKUP_FILE}