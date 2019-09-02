FROM ruby:2.6.4-alpine3.10

WORKDIR /var/www/appname

# ビルドに必要なファイルだけ先にコピーしておく。
COPY Gemfile Gemfile.lock ./

RUN \
	# 実行時に必要なパッケージ。
	apk add \
		libressl2.7-libssl \
		mariadb-connector-c \
		tzdata \
	\
	# ビルド時にのみ必要なパッケージ。後で消す。
	&& apk add --virtual .build-deps \
		build-base \
		mariadb-dev \
	\
	# apk キャッシュを削除。
	&& rm -rf /var/cache/apk/* \
	\
	# タイムゾーンは全体的に Asia/Tokyo に統一する。
	&& cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
	\
	# 実行ユーザ appname を作成。
	&& mkdir -p /home/appname \
	&& addgroup -S appname \
	&& adduser -DSh /home/appname -s /sbin/nologin -G appname appname \
	&& chmod 700 /home/appname \
	&& chown appname:appname /home/appname \
	\
	# 必要なディレクトリを作成。
	&& mkdir log tmp \
	&& cd tmp \
	&& mkdir cache pids sockets storage \
	&& cd .. \
	&& chown -R appname:appname log tmp \
	\
	# ビルド
	&& bundle -j $(nproc) --deployment --without development test \
	\
	# bundler のキャッシュを消す。
	&& rm -rf /root/.bundle \
	\
	# ビルド用のパッケージを消す。
	&& apk del .build-deps

# その他ファイルを追加。
# キャッシュを効かせるため、変更される可能性の低い順に指定する。
COPY config.ru package.json Rakefile yarn.lock ./
COPY bin bin/
COPY public public/
COPY lib lib/
COPY config config/
COPY db db/
COPY app app/

ARG RAILS_ASSETS_ENV=production

RUN \
	# Windows で docker build した場合のパーミッションの調整。
	find . -type d ! -path './vendor/*' -print0 | xargs -0 chmod 755 \
	&& find . -type f ! -path './vendor/*' -print0 | xargs -0 chmod 644 \
	&& chmod 755 bin/* \
	\
	# アセットのビルドに必要なパッケージ。後で消す。
	&& apk add --virtual .assets-build-deps \
		nodejs \
		yarn \
	&& rm -rf /var/cache/apk/* \
	\
	# アセットのビルド。
	&& RAILS_ENV=${RAILS_ASSETS_ENV} bundle exec rails assets:precompile \
	\
	# アセットのビルドで生成された不要なファイルを消す。
	&& yarn cache clean \
	&& rm -rf node_modules tmp/cache/* /tmp/* \
	\
	# ビルド用のパッケージを消す。
	&& apk del .assets-build-deps

USER appname
