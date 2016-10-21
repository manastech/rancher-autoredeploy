require "logger"

module Rancher::Autoredeploy

  @@logger : ::Logger?

  def self.logger
    @@logger ||= ::Logger.new(STDOUT).tap do |l|
      severity = Rancher::Autoredeploy.log_severity
      l.level = ::Logger::Severity.parse(severity)
    end
  end

  module Logger
    def logger
      Rancher::Autoredeploy.logger
    end
  end

end
