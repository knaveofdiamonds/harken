module Harken
  # A simple XMPP bot. This wraps the xmpp4r client library and provides a
  # simple interface.
  #
  # This bot is mainly intended to provide an interface to other non-room related
  # systems via defined Responders, so there are lots of room interactions that
  # you can't do with this bot (setting the topic, kicking users etc.)
  #
  # Any Responders that you have defined will apply to the bot.
  class Bot
    # The XMPP client
    attr_reader :connection

    # Creates a new bot. You need to provide some options:
    #
    # ==== Required
    #
    # [+user+:] User name of the account to log in with
    # [+host+:] the XMPP Domain
    #   
    # ==== Optional
    #
    # [+name+:] the name of the bot (resource in XMPP-speak). If not provided will be the same as user
    # [+password+:] account password, if required
    # [+conference+:] a default conference server domain
    # 
    def initialize(options={})
      [:user, :host, :name, :password, :conference].each do |option|
        instance_variable_set("@#{option}".to_sym, options[option])
      end
      raise "You must provide a name and an xmpp host" unless @user && @host
      @name ||= @user
      @room_clients = {}
      @responders = ResponderGroup.new
      @bot_reg_exp = /^\s*#{@name}:?\s+(.*)/
    end

    # Joins a room. Takes either a JID, or a room string and optionally a conference server
    # & resource name.
    def join(*args)
      connect unless @connection
      
      id = jid_from_args(*args)
      @room_clients[id] = Jabber::MUC::SimpleMUCClient.new(@connection)
      assign_bot_callback_procs(@room_clients[id])
      @room_clients[id].join(id)
    end

    # Leaves a room. Takes either a JID, or a room string and optionally a conference server
    # & resource name.
    def leave(*args)
      id = jid_from_args(*args)
      @room_clients.delete(id).exit if @room_clients.has_key?(id)
    end

    # Polls the xmpp connection and sleeps for a short while. Intended to be used within a 
    # daemon loop of some description.
    def breath(time=10)
      @connection.send(" ")
      sleep time
    end
    
    private

    # Returns a JID for a room.
    def jid_from_args(*args)
      return args.first if args.size == 1 && args.first.kind_of?(Jabber::JID)
      
      room, host, resource = args
      Jabber::JID.new(room, host || @conference, resource || @name)
    end
    
    # Connects to an XMPP Server.
    def connect
      @connection = Jabber::Client.new( Jabber::JID.new(@user, @host, @name) )
      @connection.connect
      @connection.auth(@password) if @password
    end

    # Attaches callbacks to chat client, directing messages to a ResponderGroup / Responder.
    def assign_bot_callback_procs(bot)
      bot.on_message do |time,nick,message|
        match = @bot_reg_exp.match(message)
        if match
          @responders.receive(match[1]).each {|reply| bot.say(reply) }
        end
      end

      bot.on_private_message do |time,nick,message|
        responder.receive(message).each {|reply| bot.say(reply,nick) }
      end
    end
  end
end
