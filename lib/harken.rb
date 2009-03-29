root = File.expand_path(File.dirname(__FILE__))
require 'xmpp4r'
require 'xmpp4r/muc'
require 'treetop'
require "#{root}/message"
require "#{root}/parser_ext"
require "#{root}/responder"
require "#{root}/responder_group"
require "#{root}/bot"
