begin
  require "em-mongo"
rescue LoadError => error
  raise "Missing EM-Synchrony dependency: gem install em-mongo"
end

module EM
  module Mongo

    class Database
      def authenticate(username, password)
        auth_result = self.collection(SYSTEM_COMMAND_COLLECTION).first({'getnonce' => 1})

        auth                 = BSON::OrderedHash.new
        auth['authenticate'] = 1
        auth['user']         = username
        auth['nonce']        = auth_result['nonce']
        auth['key']          = EM::Mongo::Support.auth_key(username, password, auth_result['nonce'])

        auth_result2 = self.collection(SYSTEM_COMMAND_COLLECTION).first(auth)
        if EM::Mongo::Support.ok?(auth_result2)
          true
        else
          raise AuthenticationError, auth_result2["errmsg"]
        end
      end
      
      %w(collections create_collection drop_collection drop_index index_information get_last_error error? add_user).each do |name|
        class_eval <<-EOS, __FILE__, __LINE__
          alias :a#{name} :#{name}
          def #{name}(*args)
            f = Fiber.current
            response = a#{name}(*args)
            response.callback { |res| f.resume(res) }
            response.errback {|res| f.resume(res) }
            Fiber.yield
          end
        EOS
      end
      
      # need to redefine collection_names because it relies on a cursor
      def collection_names
        response = RequestResponse.new
        name_resp = collections_info.adefer_as_a
        name_resp.callback do |docs|
          names = docs.collect{ |doc| doc['name'] || '' }
          names = names.delete_if {|name| name.index(self.name).nil? || name.index('$')}
          names = names.map{ |name| name.sub(self.name + '.','')}
          response.succeed(names)
        end
        name_resp.errback { |err| response.fail err }
        response
      end
      
      if defined?(EM::Mongo::Cursor)
        # need to rewrite this command since it relies on Cursor being async
        def command(selector, opts={})
          check_response = opts.fetch(:check_response, true)
          raise MongoArgumentError, "command must be given a selector" unless selector.is_a?(Hash) && !selector.empty?

          if selector.keys.length > 1 && RUBY_VERSION < '1.9' && selector.class != BSON::OrderedHash
            raise MongoArgumentError, "DB#command requires an OrderedHash when hash contains multiple keys"
          end

          response = RequestResponse.new
          cmd_resp = Cursor.new(self.collection(SYSTEM_COMMAND_COLLECTION), :limit => -1, :selector => selector).anext_document

          cmd_resp.callback do |doc|
            if doc.nil?
              response.fail([OperationFailure, "Database command '#{selector.keys.first}' failed: returned null."])
            elsif (check_response && !EM::Mongo::Support.ok?(doc))
              response.fail([OperationFailure, "Database command '#{selector.keys.first}' failed: #{doc.inspect}"])
            else
              response.succeed(doc)
            end
          end

          cmd_resp.errback do |err|
            response.fail([OperationFailure, "Database command '#{selector.keys.first}' failed: #{err[1]}"])
          end

          response
        end
      end
    end

    class Connection
      def initialize(host = DEFAULT_IP, port = DEFAULT_PORT, timeout = nil, opts = {})
        f = Fiber.current

        @em_connection = EMConnection.connect(host, port, timeout, opts)
        @db = {}
        # establish connection before returning
        @em_connection.callback { f.resume }
        
        # not sure how the resume mechanics work here - going to ignore for now
        # @em_connection.errback { f.resume; @on_close.call }
        
        Fiber.yield
      end
    end
    
    

    class Collection

      #
      # The upcoming versions of EM-Mongo change Collection#find's interface: it
      # now returns a deferrable cursor YAY. This breaks compatibility with past
      # versions BOO. We'll just choose based on the presence/absence of
      # EM::Mongo::Cursor YAY
      #

      #
      # em-mongo version > 0.3.6
      #
      if defined?(EM::Mongo::Cursor)

        # changed to make the cursor sync for versions greater than 0.3.6
        # this means find and afind are the same
        
        # afind_one is rewritten to call anext_document on the cursor returned from find
        # find_one  is sync in the original form, unchanged because cursor is changed
        # first     is sync, an alias for find_one

        alias :afind :find

        # need to rewrite afind_one manually, as it calls next_document on
        # the cursor

        def afind_one(spec_or_object_id=nil, opts={})
          spec = case spec_or_object_id
                 when nil
                   {}
                 when BSON::ObjectId
                   {:_id => spec_or_object_id}
                 when Hash
                   spec_or_object_id
                 else
                   raise TypeError, "spec_or_object_id must be an instance of ObjectId or Hash, or nil"
                 end
          find(spec, opts.merge(:limit => -1)).anext_document
        end
        alias :afirst :afind_one
        alias :first :find_one

      #
      # em-mongo version <= 0.3.6
      #
      else

        alias :afind :find
        def find(selector={}, opts={})

          f = Fiber.current
          cb = proc { |res| f.resume(res) }

          skip  = opts.delete(:skip) || 0
          limit = opts.delete(:limit) || 0
          order = opts.delete(:order)

          @connection.find(@name, skip, limit, order, selector, nil, &cb)
          Fiber.yield
        end

        # need to rewrite afirst manually, as it calls 'find' (reasonably
        # expecting it to be what is now known as 'afind')

        def afirst(selector={}, opts={}, &blk)
          opts[:limit] = 1
          afind(selector, opts) do |res|
            yield res.first
          end
        end

        def first(selector={}, opts={})
          opts[:limit] = 1
          find(selector, opts).first
        end
      end

    end

    if defined?(EM::Mongo::Cursor)
      class Cursor
      
        # Get the next document specified the cursor options.
        #
        # @return [Hash, Nil] the next document or Nil if no documents remain.
        alias :anext_document :next_document
        def next_document
          f = Fiber.current
          response = anext_document()
          response.callback { |res| f.resume(res) }
          response.errback {|res| f.resume(res) }
          Fiber.yield
        end
        alias :next :next_document
        
        # Determine whether this cursor has any remaining results.
        #
        alias :ahas_next? :has_next?
        def has_next?
          f = Fiber.current
          response = ahas_next?
          response.callback { |res| f.resume(res) }
          response.errback {|res| f.resume(res) }
          Fiber.yield
        end
        
        alias :aexplain :explain
        def explain
          f = Fiber.current
          response = aexplain
          response.callback { |res| f.resume(res) }
          response.errback {|res| f.resume(res) }
          Fiber.yield
        end
        
        alias :acount :count
        def count(*args)
          f = Fiber.current
          response = acount(*args)
          response.callback { |res| f.resume(res) }
          response.errback {|res| f.resume(res) }
          Fiber.yield
        end
        
        alias :adefer_as_a :defer_as_a
        def defer_as_a
          f = Fiber.current
          response = adefer_as_a
          response.callback {|res| f.resume(res) }
          response.errback {|res| f.resume(res) }
          Fiber.yield
        end
        
        alias :to_a :defer_as_a
        alias :ato_a :adefer_as_a
        
        def each(&blk)
          raise "A callback block is required for #each" unless blk
          EM.next_tick do
            next_doc_resp = anext_document
            next_doc_resp.callback do |doc|
              blk.call(doc)
              doc.nil? ? close : self.each(&blk)
            end
            next_doc_resp.errback do |err|
              if blk.arity > 1
                blk.call(:error, err)
              else
                blk.call(:error)
              end
            end
          end
        end
        
      end
    end
  end
end
