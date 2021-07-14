# auto_migration

## 使い方
.envファイルをコピー
```bash
cp .env.example .env
```

コピー後、DB_HOST、DB_USERなどを設定する。

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