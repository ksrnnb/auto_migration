#!/bin/bash

# 実行したいsqlファイルが入っているディレクトリ
UP_DIR="./migration/up"
SEEDER_DIR="./migration/seeders"

# 想定していない引数を指定した場合に表示する
function usage() {
  cat <<EOF

arguments: up|fresh|seed

  up: create database and tables
  
  fresh: drop database, recreate database and tables

  seed: execute seeder sql queries

EOF
}

# 名前の昇順にsqlを実行する
function executeSQL() {
  DIR="$1"
  FILES=`ls $DIR | grep .sql`

  TMP_SQL_FILE="/tmp/migrate_file.sql"
  touch $TMP_SQL_FILE

  # mysqlサーバーに接続する回数を減らすために、ひとつのファイルにまとめる
  for FILE in $FILES
  do
    cat "${DIR}/${FILE}" >> $TMP_SQL_FILE
  done

  mysql -u $DB_USER -h $DB_HOST -p$DB_PASSWORD $DB_NAME < $TMP_SQL_FILE

  rm $TMP_SQL_FILE
}

# 全テーブルの削除
function dropTables() {
  DROP_SQL="DROP DATABASE IF EXISTS ${DB_NAME}; CREATE DATABASE ${DB_NAME};"
  mysql -u $DB_USER -h $DB_HOST -p$DB_PASSWORD -e "$DROP_SQL"
}

# データベースの作成
function createDatabase() {
  CREATE_SQL="CREATE DATABASE IF NOT EXISTS ${DB_NAME};"
  mysql -u $DB_USER -h $DB_HOST -p$DB_PASSWORD -e "$CREATE_SQL"
}

# マイグレーション実行
function migrate() {
  for ARG in "$@"
  do
    case $ARG in
      seed|--seed)
        executeSQL $SEEDER_DIR
        ;;
      up)
        createDatabase
        executeSQL $UP_DIR
        ;;
      fresh)
        dropTables
        executeSQL $UP_DIR
        ;;
      *)
        usage
        break
        ;;
    esac
  done
}

# 環境変数の読み込み
. .env

# 位置引数が0個の場合
if [ $# == 0 ]
then
  usage
fi

# マイグレーション実行
migrate "$@"

exit