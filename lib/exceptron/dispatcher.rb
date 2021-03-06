module Exceptron
  class Dispatcher
    FAILSAFE_RESPONSE = [500, {'Content-Type' => 'text/html'},
      ["<html><head><title>500 Internal Server Error</title></head>" +
       "<body><h1>500 Internal Server Error</h1>If you are the administrator of " +
       "this website, then please read this web application's log file and/or the " +
       "web server's log file to find out what went wrong.</body></html>"]]

    def initialize(consider_all_requests_local)
      @consider_all_requests_local = consider_all_requests_local
      @exception_actions_cache = {}
    end

    def dispatch(env, exception)
      log_error(exception.wrapped_exception)

      local = @consider_all_requests_local || ActionDispatch::Request.new(env).local?
      controller = exception_controller(local)
      action = exception_action(local, controller, exception)

      if action
        controller.action(action).call(env)
      else
        FAILSAFE_RESPONSE
      end
    rescue Exception => failsafe_error
      $stderr.puts "Error during failsafe response: #{failsafe_error}"
      $stderr.puts failsafe_error.backtrace.join("\n")
      FAILSAFE_RESPONSE
    end

    def exception_controller(local)
      local ? Exceptron.local_controller : Exceptron.controller
    end

    def exception_action(local, controller_klass, exception)
      controller = controller_klass.new
      @exception_actions_cache[controller_klass] ||= {}
      @exception_actions_cache[controller_klass][exception.original_exception.class] ||=
        exception.actions.find { |action| controller.available_action?(action) }
    end

    def log_error(exception)
      return unless logger

      ActiveSupport::Deprecation.silence do
        message = "\n#{exception.class} (#{exception.message}):\n"
        message << exception.annoted_source_code.to_s if exception.respond_to?(:annoted_source_code)
        message << exception.backtrace.join("\n  ")
        logger.fatal("#{message}\n\n")
      end
    end

    def logger
      defined?(Rails.logger) ? Rails.logger : Logger.new($stderr)
    end
  end
end
