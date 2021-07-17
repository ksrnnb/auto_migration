# auto_migration
SQLファイルから、マイグレーションを自動で行う。MySQLのみに対応。

## 初期設定
.envファイルをコピー
```bash
cp .env.example .env
```

コピー後、DB_HOST、DB_USERなどを設定する。

## SQLファイルを生成
日時をプレフィックスとするsqlファイルを生成する。

デフォルトでは、upディレクトリにファイルを作成する。
名前の末尾がseederの場合は、seedersディレクトリに作成する。

```bash
. migrate.sh make create_hoge_table

>> 20210717155832_create_hoge_table.sql
```

## テーブルを再生成してシーディングも実行
```bash
. migrate.sh fresh --seed
```

## テーブル生成
```bash
. migrate.sh up
```

## テーブルをdrop後、再生成
```bash
. migrate.sh fresh
```

## シーディング処理
```bash
. migrate.sh seed
```