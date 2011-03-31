require 'exceptron/engine'
require 'exceptron/exceptions'

module Exceptron
  autoload :Dispatcher,                'exceptron/dispatcher'
  autoload :ExceptionsController,      'exceptron/exceptions_controller'
  autoload :Helpers,                   'exceptron/helpers'
  autoload :LocalExceptionsController, 'exceptron/local_exceptions_controller'
  autoload :LocalHelpers,              'exceptron/local_helpers'
  autoload :Middleware,                'exceptron/middleware'
  autoload :VERSION,                   'exceptron/version'


  mattr_reader :rescue_templates
  @@rescue_templates = Hash.new('diagnostics')
  @@rescue_templates.update(
    'ActionView::MissingTemplate'        => 'missing_template',
    'ActionController::RoutingError'     => 'routing_error',
    'AbstractController::ActionNotFound' => 'unknown_action',
    'ActionView::Template::Error'        => 'template_error'
  )

  def self.enable!
    @@enabled = true
  end

  def self.disable!
    @@enabled = false
  end

  def self.enabled?
    @@enabled
  end

  def self.controller=(klass)
    class_eval "def self.controller; #{klass.name}; end", __FILE__, __LINE__
  end

  def self.local_controller=(klass)
    class_eval "def self.local_controller; #{klass.name}; end", __FILE__, __LINE__
  end

  self.enable!
  self.controller = Exceptron::ExceptionsController
  self.local_controller = Exceptron::LocalExceptionsController
end
