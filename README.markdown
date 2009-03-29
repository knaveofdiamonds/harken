Harken
======

Harken is a simple DSL for describing XMPP bots using ruby.

    require 'harken'

First create a Responder. Responders listen for specific messages directed at them:

    class HelloResponder < Harken::Responder
      listen "greet <person>" do |m|
        "hello #{m.person}"
      end
    end

You can create as many responders as you like: they'll all get registered with the bot
automatically.

Next create a bot, tell him to join a chat room, and then set up a loop so the bot
stays in the room. You'll probably want to use the daemons library or similar for real
world use:

    bot = Harken::Bot.new(:user => "bot", 
                          :host => "localhost",
                          :password => "secret", 
                          :conference => "conference.localhost")
    bot.join("testroom")
    loop { bot.breath }

At the moment the bot needs to have his account already set up, and the room needs to
exist.

Anytime a user sends a private message to the bot, or when a user says "bot: some message"
in a chat room the bot is in, the bot will scan through all the listen rules and execute
the associated block.

How to Describe what you want to listen for
-------------------------------------------

Harken has its own mini-language to describe what a bot should listen out for. 
This is just a text string with:

variables: 
  any word between angle brackets - i.e. <code>"&lt;variable&gt;"</code>
optional phrases: 
  anything between square brackets - i.e. <code>"[optional]"</code>

Variables will be available as methods on the match passed to the action block:

    listen "<variable>" do |match|
      # can use match.variable
    end

Optional sections can be nested:
  
    listen "some action [with optional [parts]]"
  
Dependencies
------------

* Treetop - provides parsing support for the language
* xmpp4r  - ruby xmpp library

TODO
----

* Work out a sane way of testing with XMPP streams;
* Presence doesn't work;
* The bot should be able to eavesdrop on the room to provide things like
  logging. There will probably be an Eavesdropper (like a Responder, but
  without the requirement to listen for messages beginning with the bot's
  name);
* Subclassing of Responder seems a little messy, so this may change
* very new, so probably lots of bugs to shake out.

Copyright 2009 Roland Swingler.