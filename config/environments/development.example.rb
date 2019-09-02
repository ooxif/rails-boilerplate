# frozen_string_literal: true

Rails.application.configure do
  # docker コンテナ内で動作している場合でも web console
  # にアクセスできるようにする。
  config.web_console.whitelisted_ips = %w[
    10.0.0.0/8
    172.16.0.0/12
    192.168.0.0/16
  ]

  # production 用の gem 環境で実行する場合、listen がインストールされていない。
  if defined?(Listen)
    # ホスト OS が Windows である等、ファイルの更新が反映されないケースに対応。
    config.file_watcher =
      if ENV['DISABLE_FILE_WATCH'] == 'true'
        ActiveSupport::FileUpdateChecker
      else
        ActiveSupport::EventedFileUpdateChecker
      end
  end

  # その他の設定は省略
end
