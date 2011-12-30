require "spec/mongoid/mongoid_helper"
require 'em-synchrony/mongoid'

describe Mongoid::Persistence do

  before(:all) do
    EM.synchrony do
      Mongoid.from_hash({"host"=> "localhost", "database"=> "test", "pool_size"=>5})   
      [ Post, Link ].each(&:delete_all)
      Mongoid.persist_in_safe_mode = true
      Mongoid.parameterize_keys = false
      EventMachine.stop
    end
  end
  
  after(:all) do
    # EM.synchrony do
    #   begin
    #     Mongoid.from_hash({"host"=> "localhost", "database"=> "test", "pool_size"=>5})   
    #     Mongoid.persist_in_safe_mode = false
    #     Mongoid.parameterize_keys = true
    #     [ Post, Link ].each(&:delete_all)
    #   rescue RuntimeError,Exception
    #     puts $!
    #     puts "boo"
    #   ensure
    #     EM.stop
    #   end
    # end
  end

  describe ".create" do
    context "when providing attributes" do
      it "saves and returns the document" do
        post = nil
        EM.synchrony do
          Mongoid.from_hash({"host"=> "localhost", "database"=> "test", "pool_size"=>5})
          post = Post.create(:title => "Sensei", :body => "Testing 1 2 3")
          EventMachine.stop
        end

        post.should be_persisted
        post.should be_a_kind_of(Post)
      end
    end
    
    it "sets attributes, persists the document" do
      post = nil
      EM.synchrony do
        Mongoid.from_hash({"host"=> "localhost", "database"=> "test", "pool_size"=>5})   
        post = Post.create do |poster|
          poster.title = "Yahooooo"
        end
        EventMachine.stop
      end        

      post.title.should eq("Yahooooo")
      post.should be_persisted
    end
    
      context "when passing in a block" do

        it "sets attributes, persists the document" do
          post = nil
          EM.synchrony do
            Mongoid.from_hash({"host"=> "localhost", "database"=> "test", "pool_size"=>5})   
            post = Post.create do |poster|
              poster.title = "Yahooooo"
            end
            EventMachine.stop
          end        

          post.title.should eq("Yahooooo")
          post.should be_persisted
        end
      end

      context "when mass assignment role is indicated" do

        context "when attributes assigned from default role" do

          it "validates the roles for mass assignment" do
            dpost = nil
            EM.synchrony do
              Mongoid.from_hash({"host"=> "localhost", "database"=> "test", "pool_size"=>5})   
              dpost = Post.create(
                :title => "Some Title",
                :body => "Some text",
                :extra_field => "something else",
                :secure_field => "secure!"
              )
              EventMachine.stop
            end          

            dpost.title.should eq("Some Title")
            dpost.extra_field.should be_nil
            dpost.secure_field.should be_nil
          end
        end
      end

        # context "when attributes assigned from parser role" do
        # 
        #   EM.synchrony do
        #     Mongoid.from_hash({"host"=> "localhost", "database"=> "test", "pool_size"=>5})   
        #     let(:ppost) do
        #         Post.create(
        #           { :title => "Some Title 2",
        #             :body => "Some text",
        #             :extra_field => "something else",
        #             :simple_counter => 1,
        #             :secure_field => "secure!" }, :as => :parser
        #         )
        #       end
        #     end
        #     EventMachine.stop
        #   end
        # 
        #   it "sets the secure field for parser role" do
        #     ppost.secure_field.should eq("SomeLogin")
        #   end
        # 
        #   it "sets the simple_counter field for parse role" do
        #     ppost.simple_counter.should eq(1)
        #   end
        # 
        #   it "does not set the extra_field field" do
        #     ppost.extra_field.should be_nil
        #   end
        # end
        # 
        # context "when attributes assigned without protection" do
        #     
        #   EM.synchrony do
        #     Mongoid.from_hash({"host"=> "localhost", "database"=> "test", "pool_size"=>5})   
        #     let(:spost) do
        #         Post.create(
        #         { :title => "Some Title 3",
        #           :body => "Some text",
        #           :extra_field => "something else",
        #           :simple_counter => 1,
        #           :secure_field => "secure!" }, :without_protection => true
        #         )
        #     end
        #     EM.stop
        #   end
        #     
        #   it "sets the title attribute" do
        #     spost.title.should eq("Some Title 3")
        #   end
        #   
        #   it "sets the extra_field attribute" do
        #     spost.extra_field.should eq("something else")
        #   end
        #   
        #   it "sets the secure_field attribute" do
        #     spost.secure_field.should eq("secure!")
        #   end
        # end
    #   end
    # end
    # 
    # describe ".create!" do
    # 
    #   context "inserting with a field that is not unique" do
    # 
    #     context "when a unique index exists" do
    # 
    #       before do
    #         EM.synchrony do
    #           Mongoid.from_hash({"host"=> "localhost", "database"=> "test", "pool_size"=>5})   
    #           Post.create_indexes
    #           EventMachine.stop
    #         end
    #       end
    # 
    #       let!(:post) do
    #         EM.synchrony do
    #           Mongoid.from_hash({"host"=> "localhost", "database"=> "test", "pool_size"=>5})   
    #           Post.create!(:title => "Apple Pie")
    #           EventMachine.stop
    #         end
    #       end
    # 
    #       it "raises an error" do
    #         EM.synchrony do
    #           Mongoid.from_hash({"host"=> "localhost", "database"=> "test", "pool_size"=>5})   
    #           expect {
    #             Post.create!(:title => "Apple Pie")
    #           }.to raise_error
    #           EventMachine.stop
    #         end
    #       end
    #     end
    #   end
    # end
    # 
    # [ :delete, :destroy ].each do |method|
    # 
    #   describe "##{method}" do
    # 
    #     let(:post) do
    #       EM.synchrony do
    #         Mongoid.from_hash({"host"=> "localhost", "database"=> "test", "pool_size"=>5})   
    #         Post.create(:title => "218-32-6789")
    #         EventMachine.stop
    #       end
    #     end
    # 
    #     context "when removing a root document" do
    # 
    #       let!(:deleted) do
    #         EM.synchrony do
    #           Mongoid.from_hash({"host"=> "localhost", "database"=> "test", "pool_size"=>5})   
    #           post.send(method)
    #           EventMachine.stop
    #         end
    #       end
    # 
    #       it "deletes the document from the collection" do
    #         EM.synchrony do
    #           Mongoid.from_hash({"host"=> "localhost", "database"=> "test", "pool_size"=>5})   
    #           expect {
    #             Post.find(post.id)
    #           }.to raise_error
    #           EventMachine.stop
    #         end
    #       end
    # 
    #       it "returns true" do
    #         deleted.should be_true
    #       end
    # 
    #       it "resets the flagged for destroy flag" do
    #         post.should_not be_flagged_for_destroy
    #       end
    #     end
    # 
    #     context "when removing an embedded document" do
    # 
    #       let(:comment) do
    #         EM.synchrony do
    #           Mongoid.from_hash({"host"=> "localhost", "database"=> "test", "pool_size"=>5})   
    #           post.comments.build(:title => "Bond Street")
    #           EventMachine.stop
    #         end
    #       end
    # 
    #       context "when the document is not yet saved" do
    # 
    #         before do
    #           EM.synchrony do
    #             Mongoid.from_hash({"host"=> "localhost", "database"=> "test", "pool_size"=>5})   
    #             comment.send(method)
    #             EventMachine.stop
    #           end
    #         end
    # 
    #         it "removes the document from the parent" do
    #           post.comments.should be_empty
    #         end
    # 
    #         it "removes the attributes from the parent" do
    #           post.raw_attributes["comments"].should be_nil
    #         end
    # 
    #         it "resets the flagged for destroy flag" do
    #           comment.should_not be_flagged_for_destroy
    #         end
    #       end
    # 
    #       context "when the document has been saved" do
    # 
    #         before do
    #           EM.synchrony do
    #             Mongoid.from_hash({"host"=> "localhost", "database"=> "test", "pool_size"=>5})   
    #             comment.save
    #             address.send(method)
    #             EventMachine.stop
    #           end
    #         end
    # 
    #         let(:from_db) do
    #           EM.synchrony do
    #             Mongoid.from_hash({"host"=> "localhost", "database"=> "test", "pool_size"=>5})   
    #           
    #             Post.find(post.id)
    #             EventMachine.stop
    #           end
    #         end
    # 
    #         it "removes the object from the parent and database" do
    #           EM.synchrony do
    #             Mongoid.from_hash({"host"=> "localhost", "database"=> "test", "pool_size"=>5})   
    #             from_db.comments.should be_empty
    #             EventMachine.stop
    #           end
    #         end
    #       end
    #     end
    #   end
    # end
    # 
    # describe "#save" do
    # 
    #   let(:post) do
    #     EM.synchrony do
    #       Mongoid.from_hash({"host"=> "localhost", "database"=> "test", "pool_size"=>5})
    #       Post.new(:title => "811-82-8345")
    #       Eventmachine.stop
    #     end
    #   end
    # 
    #   context "when saving with a hash field with invalid keys" do
    # 
    #     before do
    #       post.map = { "bad.key" => "value" }
    #     end
    # 
    #     it "raises an error" do
    #       EM.synchrony do
    #         Mongoid.from_hash({"host"=> "localhost", "database"=> "test", "pool_size"=>5})   
    #         expect { post.save }.to raise_error(BSON::InvalidKeyName)
    #         EventMachine.stop
    #       end
    #     end
    #   end
    # 
    #   context "when validation passes" do
    # 
    #     it "returns true" do
    #       EM.synchrony do
    #         Mongoid.from_hash({"host"=> "localhost", "database"=> "test", "pool_size"=>5})   
    #         post.save.should be_true
    #         EventMachine.stop
    #       end
    #     end
    #   end
    # 
    #   context "when validation fails" do
    # 
    #     let(:comment) do
    #       EM.synchrony do
    #         Mongoid.from_hash({"host"=> "localhost", "database"=> "test", "pool_size"=>5})   
    #         post.comment.create(:body => "London Pants")
    #         EventMachine.stop
    #       end
    #     end
    # 
    #     before do
    #       EM.synchrony do
    #         Mongoid.from_hash({"host"=> "localhost", "database"=> "test", "pool_size"=>5})   
    #       
    #         comment.save
    #         EventMachine.stop
    #       end
    #     end
    # 
    #     it "has the appropriate errors" do
    #       comment.errors[:title].should eq(["can't be blank"])
    #     end
    #   end
    # 
    # end
    # 
    # describe "save!" do
    # 
    #   context "when saving with a hash field with invalid keys" do
    # 
    #     let(:post) do
    #       EM.synchrony do
    #         Mongoid.from_hash({"host"=> "localhost", "database"=> "test", "pool_size"=>5})   
    #         Post.new
    #         EventMachine.stop
    #       end
    #     end
    # 
    #     before do
    #       post.map = { "bad.key" => "value" }
    #     end
    # 
    #     it "raises an error" do
    #       EM.synchrony do
    #         Mongoid.from_hash({"host"=> "localhost", "database"=> "test", "pool_size"=>5})   
    #         expect { post.save! }.to raise_error(BSON::InvalidKeyName)
    #         EventMachine.stop
    #       end
    #     end
    #   end
    # 
    #   context "inserting with a field that is not unique" do
    # 
    #     context "when a unique index exists" do
    # 
    #       let(:post) do
    #         EM.synchrony do
    #           Mongoid.from_hash({"host"=> "localhost", "database"=> "test", "pool_size"=>5})   
    #           Post.new(:title => "555-55-9999")
    #           EventMachine.stop
    #         end
    #       end
    # 
    #       before do
    #         EM.synchrony do
    #           Mongoid.from_hash({"host"=> "localhost", "database"=> "test", "pool_size"=>5})   
    #           Post.create!(:title => "555-55-9999")
    #           EventMachine.stop
    #         end
    #       end
    # 
    #       it "raises an error" do
    #         EM.synchrony do
    #           Mongoid.from_hash({"host"=> "localhost", "database"=> "test", "pool_size"=>5})   
    #           expect { post.save! }.to raise_error
    #           EventMachine.stop
    #         end
    #       end
    #     end
    #   end
    
  end
end
