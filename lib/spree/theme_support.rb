require_dependency 'spree/theme_support/hook'
require 'spree/theme_support/more_patches'

ActionController::Base.helper Spree::ThemeSupport::HookHelper
