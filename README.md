# ruby v2.6.4 + Rails v6.0.0 + MySQL + Docker ボイラープレート

- [環境変数](#env-vars)
- [使い方](#how-to-use)
- [rails / rubocop / rspec などのコマンドの実行方法について](#rails-commands)
- [MySQL へのログインについて](#mysql)
- [Rails から送信されるメールについて](#smtp)
- [プロジェクトの運用について](#rules)
    - [docker-compose.yml の変更および docker-compose.override.yml について](#rules-docker)
    - [RuboCop の設定 .rubocop.yml について](#rules-rubocop)

<a name="env-vars">

## 環境変数

| 環境変数             | 説明                 | 主な利用箇所                         |
| -------------------- | -------------------- | ------------------------------------ |
| `DATABASE_*`         | データベース接続設定 | `config/database.yml`                |
| `DISABLE_FILE_WATCH` | 開発環境用           | `config/environments/development.rb` |
| `SMTP_*`             | SMTP設定             | `config/smtp.yml`                    |

<a name="how-to-use">

## 使い方

1. このリポジトリを git clone し、そのディレクトリに移動します。
2. プロジェクト内の全ファイルに対して、 `appname` となっている箇所を
   アプリケーション名に置換します。  
   `find * -type f | xargs sed -i 's/appname/xxx/g'` で可能です。  
   (xxx にアプリケーション名を入れます)
3. `docker-compose run --rm app bundle --path=vendor/bundle` を実行し、
    gem をインストールします。  
    vendor ディレクトリおよび .bundle ディレクトリ、 Gemfile.lock ファイルが
    作成されます。
4. `docker-compose run --rm app bundle exec rails new . -G -s -d mysql`
    を実行し、 Rails プロジェクトを初期化します。  
    なお Rails v6.0.0 では、 -G オプションを指定しても .gitignore に内容が
    追加されてしまい、その内容が重複してしまっているので、
    `git checkout -- .gitignore` で元に戻します。
5. `config/application.example.rb` の設定例を `config/application.rb` に、
   `config/environments/development.example.rb` の設定例を
   `config/environments/development.rb` に適切にコピーします。  
   その後、これらの 2 つの .example.rb ファイルは削除します。
6. `docker-compose.override.example.yml` を `docker-compose.override.yml`
   としてコピーします。  
   必要に応じて内容を編集してください。
5. `docker-compose up` で各種コンテナを起動します。  
   `Puma starting in single mode...` ～ `Use Ctrl-C to stop` が表示されたら
   起動完了です。
6. http://localhost:3000 にアクセスし Rails の画面が表示されたら
   動作確認完了です。
7. `git add .` `git commit -m 'init'` し、初期化時の状態をコミットします。

<a name="rails-commands">

## rails / rubocop / rspec などのコマンドの実行方法について

コンテナが起動中の場合は、 `docker-compose exec app sh` コマンドを実行して
app のシェルに入り、その中で `bin/rails` `bin/rubocop` などのコマンドを
実行します。

なお、わざわざ app のシェルに入らなくても、コンテナが起動中であれば    
`docker-compose exec app bin/rails ...`  
コンテナが停止中であれば  
`docker-compose run --rm app bin/rails ...`  
のように docker-compose exec もしくは docker-compose run コマンドを利用
することで各種コマンドを実行することは可能ですが、
`Spring` による連続実行の速度改善の恩恵を受けるためにも、
app のシェルに入ったほうが作業効率は良いです。

<a name="mysql">

## MySQL へのログインについて

コンテナを起動させ、 `docker-compose exec mysql mysql -uroot -proot` で
ログインできます。

<a name="smtp">

## Rails から送信されるメールについて

`config/application.rb` や `config/environments/*.rb` で

- `config.action_mailer.smtp_settings = config_for(:smtp).transform_keys(&:to_sym)`
- `config.action_mailer.delivery_method = :smtp`

が設定されていれば、 http://localhost:8025 に全てのメールが届きます。

<a name="rules">

## プロジェクトの運用について

使い方の話ではないため、以下は取捨選択をお願いします。

<a name="rules-docker">

### docker-compose.yml の変更および docker-compose.override.yml について

`docker-compose.yml` は開発者全員が共有します。

個人的な都合で docker-compose.yml を変更したい場合は、
`docker-compose.override.yml` を利用して既存の設定を
上書きするようにしてください。

参考: https://qiita.com/urouro_net/items/6a026eb635cc7d0e034f

開発者全員が共有する変更の場合に docker-compose.yml を変更してください。

<a name="rules-rubocop">

### RuboCop の設定 .rubocop.yml について

基本的には RuboCop のデフォルトの設定を利用します。
(Cop の好みの差で話し合う必要をなくすため)

ただし、下記の理由で、いくつかデフォルト設定から変更しています。

- `bin/**/*` `db/schema.rb` は自動生成されるものと想定しているため、
  除外しています。
- `db/migrate/**/*` はテーブル構造によっては長くなりがちであり、
  かつメソッドを分割するとより分かりづらくなるケースが多いため、
  いくつかの Cop を除外しています。
- `spec/**/*` は describe ブロック中に it が沢山あるケースがあるため、
  Metrics/BlockLength のみ除外しています。
- `Style/AsciiComments` は日本語のコメントを書けるよう無効化しています。
- `Style/Documentation` は無駄なコメントを抑制するために無効化しています。

どうしても RuboCop が通るようにコードを書けない場合は、

```ruby
# rubocop:disable Metrics/AbcSize
# ...
# rubocop:enable Metrics/AbcSize 
```

のように、その箇所だけコメントで無効化します。

RuboCop の設定がプロジェクトの状況に合わない場合にのみ (好みが理由ではなく)、
.rubocop.yml を変更します。
