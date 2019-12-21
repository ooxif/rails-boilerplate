# ruby v2.6.5 + Rails v6.0.2.1 + MySQL + Docker ボイラープレート

- [環境変数](#env-vars)
- [使い方](#how-to-use)
- [rails / rubocop / rspec などのコマンドの実行方法について](#rails-commands)
- [MySQL へのログインについて](#mysql-cli)
- [MySQL のユーザ/デターベースについて](#mysql-naming)
- [Rails から送信されるメールについて](#smtp)
- [プロジェクトの運用について](#rules)
    - [docker-compose.yml の変更および docker-compose.override.yml について](#rules-docker)
    - [RuboCop の設定 .rubocop.yml について](#rules-rubocop)
    - [ERB / Javascript / CSS のリンティングについて](#rules-yarn)

<a name="env-vars">

## 環境変数

| 環境変数             | 説明                 | 主な利用箇所                         |
| -------------------- | -------------------- | ------------------------------------ |
| `DATABASE_*`         | データベース接続設定 | `config/database.yml`                |
| `DISABLE_FILE_WATCH` | 開発環境用           | `config/environments/development.rb` |
| `SMTP_*`             | SMTP設定             | `config/smtp.yml`                    |

<a name="how-to-use">

## 使い方

Docker
([Mac](https://docs.docker.com/docker-for-mac/install/)
[Windows](https://docs.docker.com/docker-for-windows/install/)
[Linux](https://docs.docker.com/install/linux/docker-ce/centos/))
および [Docker Compose](https://docs.docker.com/compose/install/)
は最新の安定版を利用してください。

1. このリポジトリを git clone し、そのディレクトリに移動します。
2. プロジェクト内の全ファイルに対して、 `appname` となっている箇所を
   アプリケーション名に置換します。  
   `docker run --rm -v "$(pwd):/v" busybox sh -c 'find /v/* -type f | xargs sed -i "s/appname/xxx/g"'`
   で可能です。  
   (xxx にアプリケーション名を入れます)
3. `docker-compose run --rm app bundle` を実行し、 gem をインストールします。  
    Gemfile.lock ファイルが作成されます。  
    > Linux で開発する場合、パーミッションの問題を避けるため、
    > このコマンドを実行する前に  
    > `chmod a+w . .gitignore && chmod -R a+w *`  
    > を実行してください。
4. `docker-compose run --rm app bundle exec rails new . -G -s -d mysql`
    を実行し、 Rails プロジェクトを初期化します。  
    なお Rails v6.0.0 では、 -G オプションを指定しても .gitignore に内容が
    追加されてしまい、その内容が重複してしまっているので、
    `git checkout -- .gitignore` で元に戻します。
5. `docker-compose run --rm app bundle exec rails g rspec:install` で rspec を
   初期化します。  
   spec ディレクトリが作成されます。  
   なお今後 test ディレクトリは使用しないため、 test ディレクトリは
   削除してください。
6. `config/application.example.rb` の設定例を `config/application.rb` に、
   `config/environments/development.example.rb` の設定例を
   `config/environments/development.rb` の適切な箇所に追記します。  
   その後、これらの 2 つの .example.rb ファイルは削除します。
7. `docker-compose.override.example.yml` を `docker-compose.override.yml`
   としてコピーします。  
   必要に応じて内容を編集してください。
8. `docker-compose up` で各種コンテナを起動します。  
   `Puma starting in single mode...` ～ `Use Ctrl-C to stop` が表示されたら
   起動完了です。
9. http://localhost:3000 にアクセスし Rails の画面が表示されたら
   動作確認完了です。
10. `.git` ディレクトリを削除し、新たに git を初期化します。  
    `rm -rf .git && git init .` で可能です。  
    > Windows PowerShell なら  
    > `Remove-Item -Recurse -Force .git; git init .`  
    > です。
11. `git add .` `git commit -m 'init'` し、初期化時の状態をコミットします。

<a name="rails-commands">

## rails / rubocop / rspec などのコマンドの実行方法について

コンテナが起動中の場合は、 `docker-compose exec app sh` コマンドを実行して
app のシェルに入り、その中で `rails` `rubocop` などのコマンドを実行します。

なお、わざわざ app のシェルに入らなくても、コンテナが起動中であれば    
`docker-compose exec app rails ...`  
コンテナが停止中であれば  
`docker-compose run --rm app rails ...`  
のように docker-compose exec もしくは docker-compose run コマンドを利用
することで各種コマンドを実行することは可能ですが、
`Spring` による連続実行の速度改善の恩恵を受けるためにも、
app のシェルに入ったほうが作業効率は良いです。

> bin に PATH が最優先で通っているため、 bin/rails とせず rails とするだけで
> bin/rails が実行されます。

<a name="mysql-cli">

## MySQL へのログインについて

コンテナを起動させ、 `docker-compose exec mysql mysql -uroot -proot` で
ログインできます。

<a name="mysql-naming">

## MySQL のユーザ/データベースについて

> 以下 appname となっている箇所は、使い方の 2 によってアプリケーション名に
> 置換されているはずです。  
> 適宜読み替えてください。

| ユーザ名               | パスワード   | 権限                                             | 作成箇所                                                          |
| ---------------------- | ------------ | ------------------------------------------------ | ----------------------------------------------------------------- |
| `root`                 | `root`       | 全権限                                           | `docker-compose.yml`                                              |
| `appname_development`  | `appname`    | `appname_development` データベースに対する全権限 | `containers/mysql/docker-entrypoint-initdb.d/01_create_users.sql` |
| `appname_test`         | `appname`    | `appname_test*` データベースに対する全権限       | `containers/mysql/docker-entrypoint-initdb.d/01_create_users.sql` |

| データベース名        | 作成箇所                                                              |
| --------------------- | --------------------------------------------------------------------- |
| `appname_development` | `containers/mysql/docker-entrypoint-initdb.d/02_create_databases.sql` |
| `appname_test`        | `containers/mysql/docker-entrypoint-initdb.d/02_create_databases.sql` |
| `appname_test*`       | -                                                                     |

MySQL は [Docker 公式イメージ](https://hub.docker.com/_/mysql) を使っています。

- AWS RDS Aurora for MySQL へ移行しやすくするため、
  v8.0 系ではなく v5.7 系を利用します。
- root パスワードは `docker-compose.yml` の
  [`MYSQL_ROOT_PASSWORD`](https://github.com/docker-library/docs/tree/5dcedf91847647b9e044268f57862194d7c79ddd/mysql#mysql_root_password)
  環境変数で設定しています。
- その他ユーザおよびデータベースは
  [`docker-entrypoint-init.d`](https://github.com/docker-library/docs/tree/5dcedf91847647b9e044268f57862194d7c79ddd/mysql#initializing-a-fresh-instance)
  ディレクトリ以下の SQL が初回起動時に自動的に実行されて作成されます。

`config/database.yml` にて、ユーザ名、データベース名に環境名が自動的に
付与されるよう設定しています。  
これは意図していないデータベースに間違ってアクセスしてしまわないようにするため、  
また development 環境で動作している app コンテナからでも
(test 環境で動作させる) テストを実行しやすくするためです。

上記の通り環境名は `config/database.yml` で付与されるので、
`docker-compose.yml` の `DATABASE_NAME` および `DATABASE_USERNAME` 環境変数は、
環境名を除いた部分のみ設定します。  
(`appname_development` と設定するのではなく、ただ `appname` と設定します)

`appname_test*` データベースは、テストを並列実行する場合に作成/使用される
(と想定される) データベースです。  
ただし、このリポジトリでは、テストの並列実行は設定していません。  
テストの並列実行を実現する gem は複数あり、それぞれに長所短所、
好みがあるためです。

例えば [parallel_tests](https://github.com/grosser/parallel_tests)
を利用するならば、 `config/database.yml` の `test` の箇所を以下のように修正する
ことになると思います。

```yaml
test:
  <<: *default
  database: <%= ENV.fetch('DATABASE_NAME') %>_test<%= ENV['TEST_ENV_NUMBER'] %>
```

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

なお ERB のリンティングには以下の `yarn` コマンドを利用します。

<a name="rules-yarn">

### ERB / Javascript / CSS のリンティングについて

以下のツールを利用します。

- [erb-lint](https://github.com/Shopify/erb-lint)
  - .erb のリンティング/フォーマットに利用します。
  - とりあえずだいたいのリンターを有効にしていますが、プロジェクトの状況に応じて
    いくつかは無効化してもいいかと思います。
    (多言語化する予定のないプロジェクトで HardCodedString を無効化する等)
- [ESLint](https://eslint.org/)
  - .js のリンティング/フォーマットに利用します。
  - 推奨設定 (eslint:recommended plugin:prettier/recommended) を利用します。
- [prettier](https://prettier.io/)
  - .json のリンティング/フォーマットに利用します。
  - デフォルトの設定を利用します。
- [stylelint](https://stylelint.io/)
  - .css .scss のリンティング/フォーマットに利用します。
  - 推奨設定 (stylelint-prettier/recommended stylelint-config-recommended-scss)
    およびプロパティのA-Z順並び替えルール (order/properties-alphabetical-order)
    を利用します。

.css .erb .js .json .scss の lint は `yarn` コマンドで実行します。  
`yarn` コマンドは `Spring` のような効率化の処理はないので、
app のシェルに入ってコマンドを実行してもいいですし、
`docker-compose exec` `docker-compose run` で実行しても変わりはありません。

```sh
# 全ての .css .erb .js .json .scss に対して lint を実行します。
yarn lint

# .css .erb .js .json .scss のうち、変更したファイルだけに対して lint
# を実行します。
yarn linc

# 指定したファイルのみ lint します。
yarn linc:css some-css-file.css
yarn linc:erb some-erb-file.erb
yarn linc:js some-js-file.js
yarn linc:json some-json-file.json

# lint となっている箇所を fix 、 linc となっている箇所を fic とすると、
# 自動的に修正されます。 (自動修正が可能である項目のみ)
```

RuboCop 同様、プロジェクトの状況に合わない場合にのみ、
それぞれの設定を変更します。
