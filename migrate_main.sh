#!/bin/bash

# 実行したいsqlファイルが入っているディレクトリ
UP_DIR="./migration/up"
SEEDER_DIR="./migration/seeders"

# 想定していない引数を指定した場合に表示する
function usage() {
  cat <<EOF

arguments: up|fresh|seed|make

  up: create database and tables
  
  fresh: drop database, recreate database and tables

  seed: execute seeder sql queries

  make: make migration file

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
  case "$1" in
    seed)
      executeSQL $SEEDER_DIR
      ;;
    up)
      createDatabase
      executeSQL $UP_DIR
      ;;
    fresh)
      dropTables
      executeSQL $UP_DIR
      if [ "$2" = --seed ]
      then
          executeSQL $SEEDER_DIR
      fi
      ;;
    make)
      fileName="$2"
      dir=""
      if [ "${fileName: -6}" = seeder ] || [ "${fileName: -6}" = Seeder ]
      then
        dir="$SEEDER_DIR"
      else
        dir="$UP_DIR"
      fi
      touch "$dir"/`date +%Y%m%d%H%M%S_"$2".sql`
      ;;
    *)
      usage
      break
      ;;
  esac
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