class Link
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :url
  
  belongs_to :post
  
end