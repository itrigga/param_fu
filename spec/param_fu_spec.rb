require File.join( File.dirname(__FILE__), 'spec_helper' )

class Tester
  include Trigga::ParamFu
end

describe Trigga::ParamFu do
  before(:each) do
    @t = Tester.new
  end
  describe "Hash.to_conditions" do
    before(:each) do
      @my_hash = { :blart=>'flange', :cheese=>'provolone', :ham=>'mortadella' }
    end
    
    it "should return an array" do
      @my_hash.to_conditions(:blart).class.should == Array
    end
    
    describe "for each key in the hash" do
      describe "when it's in the given allowed_keys" do
        
        it "should appear in the first element" do
          @my_hash.to_conditions( :blart )[0].should =~ /blart/
        end
        
        it "should append the value to the array" do
          @my_hash.to_conditions(:blart).should include('flange')
        end
        
      end
      
      describe "when it's NOT in the given allowed_keys" do
        it "should not appear in the first element" do
          @my_hash.to_conditions( :donkey )[0].should_not =~ /donkey/
        end
      end
    end
    
    context "when column aliases are given" do
      describe "for each given alias" do
        it "should map the param called (key) to a returned column called (alias[key])" do
          @my_hash.to_conditions(:blart, :blart=>'aliased_blart')[0].should =~ /aliased_blart\s*=\s*?/
        end
      end
    end
  end
  
  describe "class methods" do
    
    describe "key_with_id" do
      it "should add '_id' onto the given symbol" do
        Tester.key_with_id(:blart).should == :blart_id
      end
    end
    
    describe "obj_or_id" do
      describe "when the given hash already contains :(given_key)_id" do
        it "should not change the value of that _id key" do
          @my_obj = mock("object")
          @my_obj.stub!(:id).and_return(456)
          @my_hash = {:my_key_id=>123, :my_obj=>@my_obj}
          Tester.obj_or_id( @my_hash, :my_key )
          @my_hash[:my_key_id].should == 123
        end
      end
      
      describe "when the given hash does not already contain :(given_key)_id" do
        
        describe "and the given hash contains the given key without an added _id" do
          it "should set the :(given_key)_id to the id of the object" do
            @mock_obj = mock("obj")
            @mock_obj.stub!(:id).and_return(123)
            Tester.obj_or_id( {:my_obj=>@mock_obj}, :my_obj ).should == 123
          end
        end
      end
    end
    
    describe "require_param" do
      context "when key is not present in opts" do
        it "should raise an ArgumentError" do
          lambda{ Tester.require_param( {:key1=>'value1'}, :key2 ) }.should raise_error(ArgumentError)
        end
      end
      context "when key is present in opts" do
        it "should not raise an error" do
          lambda{ Tester.require_param( {:key1=>'value1'}, :key1 ) }.should_not raise_error(ArgumentError)
        end
      end
      
    end
  
    describe "require_obj_or_id" do
      context "when the key is present" do
        it "should not raise an error" do
          lambda{ Tester.require_obj_or_id( {:obj_name=>'value1'}, :obj_name ) }.should_not raise_error(ArgumentError)
        end
      end
      context "when the key is not present" do
        context "when the key suffixed with _id is present" do
          it "should not raise an error" do
            lambda{ Tester.require_obj_or_id( {:obj_id=>'value1'}, :obj ) }.should_not raise_error(ArgumentError)
          end
        end
        context "when the key is not present even suffixed with _id" do
          it "should raise an error" do
            lambda{ Tester.require_obj_or_id( {:key1=>'value1', :key2_id=>123}, :key3 ) }.should raise_error(ArgumentError)
          end
        end
      end
    end
    
    describe "require_one_of" do
      context "when at least one of the given keys is contained in opts" do
        it "should not raise an error" do
          lambda{ Tester.require_one_of( {:obj=>'value1'}, :foo, :bar, :obj ) }.should_not raise_error(ArgumentError)          
        end
      end
      context "when none of the given keys are contained in opts" do
        it "should raise an error" do
          lambda{ Tester.require_one_of( {:obj=>'value1'}, :foo, :bar ) }.should raise_error(ArgumentError)          
        end
      end
    end
  end
  
  describe "instance_methods" do
    describe "require_obj_or_id" do
      it "should call the class method require_obj_or_id" do
        Tester.should_receive(:require_obj_or_id).with( {:key=>'val'}, :key )
        @t.require_obj_or_id( {:key=>'val'}, :key )
      end
    end
    
    describe "obj_or_id" do
      it "should call the class method obj_or_id" do
        Tester.should_receive(:obj_or_id).with( {:key=>'val'}, :key )
        @t.obj_or_id( {:key=>'val'}, :key )
      end
    end
  end
end
