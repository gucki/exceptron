module Exceptron
  class LocalExceptionsController < ActionController::Base
    append_view_path File.expand_path("../views", __FILE__)
    include Exceptron::Helpers

    helper Exceptron::LocalHelpers

    def internal_server_error
      render :action => Exceptron.rescue_templates[exception_presenter.original_exception.class.name]
    end

    def self.inherited(subclass)
      super
      Exceptron.local_controller = subclass
    end
  end
end
