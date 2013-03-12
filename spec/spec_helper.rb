# -*- encoding : utf-8 -*-
require 'coveralls'
Coveralls.wear!

require 'rails/all'
require 'haml'
require 'simple-page-compoents'
require 'nokogiri'

$view = ActionView::Base.new
class << $view
  include Haml::Helpers
end
$view.init_haml_helpers
