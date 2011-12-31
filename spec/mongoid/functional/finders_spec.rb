require "spec/mongoid/mongoid_helper"
require 'em-synchrony/mongoid'

describe "Mongoid Finders" do
  # 
  # before(:all) do
  #   puts "starting!"
  #   EM.synchrony do
  #     Mongoid.from_hash({"host"=> "localhost", "database"=> "test", "pool_size"=>5})   
  #     Post.create(title: "Sample Post Alpha!", body: "rocking the rocker rocket. (yes, I'm tired...)")
  #     Post.create(title: "Sample Post Beta!", body: "rocking the rocker rocket. (yes, I'm tired...)")
  #     Post.create(title: "Sample Post Gamma!", body: "rocking the rocker rocket. (yes, I'm tired...)")
  #     EventMachine.stop
  #   end
  #   puts "stopped!"
  # end

  it "should find one" do
    
    post = nil

    EM.synchrony do
      begin
        Mongoid.from_hash({"host"=> "localhost", "database"=> "test", "pool_size"=>5})
        Post.create(title: "Sample Post Alpha!", body: "rocking the rocker rocket. (yes, I'm tired...)")
        Post.create(title: "Sample Post Beta!", body: "rocking the rocker rocket. (yes, I'm tired...)")
        Post.create(title: "Sample Post Gamma!", body: "rocking the rocker rocket. (yes, I'm tired...)")
        post = Post.first
      rescue Exception,Error
        puts $!
      end
      EM.stop
    end
    
    post.should_not be_nil
    post.title.should eq("Sample Post Alpha!")
    
  end

  it "should find a simple document" do
    
    doc = nil

    EM.synchrony do
      begin
        Mongoid.from_hash({"host"=> "localhost", "database"=> "test", "pool_size"=>5})
        SimpleDocument.delete_all
        SimpleDocument.create(name: "Simple Doc Alpha!")
        doc = SimpleDocument.first
      rescue Exception,Error
        puts $!
      end
      EM.stop
    end
    
    doc.should_not be_nil
    doc.name.should eq("Simple Doc Alpha!")
    
  end
  
  it "should find a Link" do
    
    link = nil

    EM.synchrony do
      begin
        Mongoid.from_hash({"host"=> "localhost", "database"=> "test", "pool_size"=>5})
        Link.delete_all
        Link.create(url: "http://fatmixx.com")
        link = Link.first
      rescue Exception,Error
        puts $!
      end
      EM.stop
    end
    
    link.should_not be_nil
    link.url.should eq("http://fatmixx.com")
    
  end
  
end