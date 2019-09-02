# 省略

module Appname
  class Application < Rails::Application
    # 省略

    # タイムゾーンを Asia/Tokyo に統一する。
    # Rails が稼働するサーバ、および MySQL サーバ (Aurora) などのタイムゾーンも
    # 必ず Asia/Tokyo もしくは適切なタイムゾーンに設定すること。
    config.time_zone = 'Tokyo'
    config.active_record.default_timezone = :local

    # SMTP の設定。ただし実際に SMTP を使うかどうかは
    # config.action_mailer.delivery_method 次第。
    # config.action_mailer.delivery_method はここで設定してもいいし、
    # config/environments/*.rb で設定してもいい。
    config.action_mailer.smtp_settings = config_for(:smtp)
                                         .transform_keys(&:to_sym)
    #config.action_mailer.delivery_method = :smtp
  end
end
