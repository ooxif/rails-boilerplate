# frozen_string_literal: true

# 省略

module Appname
  class Application < Rails::Application
    # 以下の内容を config/application.rb の `config.load_defaults 6.0` の下に
    # 追記してください。

    # タイムゾーンを Asia/Tokyo に統一する。
    # Rails が稼働するサーバ、および MySQL サーバ (Aurora) などのタイムゾーンも
    # 必ず Asia/Tokyo もしくは適切なタイムゾーンに設定すること。
    config.time_zone = 'Tokyo'
    config.active_record.default_timezone = :local

    # ActiveRecord のデフォルトのバリデーションエラーの文言などを
    # 利用できるようにするため、 available_locals に en を追加し、 fallbacks も
    # en にする。
    # 殆どのデフォルトの文言は rails-i18n によって日本語化されているはずだが、
    # rails-i18n に抜けや漏れがある場合もあるので、一応設定しておく。
    config.i18n.available_locales = %i[en ja]
    config.i18n.fallbacks = %i[en]

    # 言語を日本語に設定する。
    # 対応する言語を増やす場合に available_locales に言語を追加し、
    # https://guides.rubyonrails.org/v6.0/i18n.html#managing-the-locale-across-requests
    # を参考に言語を切り替える仕組みを別途導入する。
    # 切り替える仕組みを導入しない限りは、 default_locale で設定した言語が
    # 利用される。
    config.i18n.default_locale = :ja

    # SMTP の設定。ただし実際に SMTP を使うかどうかは
    # config.action_mailer.delivery_method 次第。
    # config.action_mailer.delivery_method はここで設定してもいいし、
    # config/environments/*.rb で設定してもいい。
    config.action_mailer.smtp_settings = config_for(:smtp)
                                         .transform_keys(&:to_sym)
    # config.action_mailer.delivery_method = :smtp
  end
end
