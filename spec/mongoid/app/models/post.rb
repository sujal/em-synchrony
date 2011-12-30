class Post
  include Mongoid::Document
  
  field :title
  field :body
  field :extra_field
  field :secure_field
  field :simple_counter, type: Integer
  
  embeds_many :comments
  
  has_many :links
  
  field :title, :type => String
  field :is_rss, :type => Boolean, :default => false
  field :user_login, :type => String

  attr_protected :extra_field, :as => [:default, :parser]
  attr_protected :simple_counter, :as => :parser
  attr_protected :secure_field
  
  index :title, :unique => true
  
  validates_presence_of :title
  
end