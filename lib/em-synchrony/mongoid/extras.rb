module EM::Mongo
  class Database
    alias :driver_create_collection :create_collection
    def create_collection(name, options=nil)
      driver_create_collection(name)
    end
  end
  
  class Collection
    alias :driver_insert :insert
    def insert(doc_or_docs,opts=nil)
      driver_insert(doc_or_docs)
    end
  end
end