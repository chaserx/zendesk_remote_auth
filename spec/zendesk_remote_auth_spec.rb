require 'spec_helper'

describe Zendesk::RemoteAuth do
  
  before(:each) do
    @auth = Object.new
    @auth.extend(Zendesk::RemoteAuthHelper)
  end
  
  context 'RemoteAuth' do
    before(:each) do
      Zendesk::RemoteAuth.token = Zendesk::RemoteAuth.auth_url = nil
    end
    
    it 'should raise exception if token is not set' do
      lambda{ Zendesk::RemoteAuth.token }.should raise_error(ArgumentError)
    end

    it 'should return the token without exception if it is set' do
      Zendesk::RemoteAuth.token = 'blah'
      Zendesk::RemoteAuth.token.should == 'blah'
    end


    it 'should raise exception if auth_url is not set' do
      lambda { Zendesk::RemoteAuth.auth_url }.should raise_error(ArgumentError)
    end

    it 'should return the auth_url without exception if it is set' do
      Zendesk::RemoteAuth.auth_url = 'blah'
      Zendesk::RemoteAuth.auth_url.should == 'blah'
    end
  end
  

  context 'url generation' do
    before(:each) do
      Zendesk::RemoteAuth.token = 'the_token'
      Zendesk::RemoteAuth.auth_url = 'the_url'
      @valid_params = { :email => 'test@example.com', :name => 'blah'}
    end
    
    context 'required fields' do
      it 'should raise an argument error the name is not provided' do
        lambda {
          @valid_params.delete(:name)
          @auth.zendesk_remote_auth_url(@valid_params)
        }.should raise_error(ArgumentError) 
      end

      it 'should raise an argument error the email is not provided' do
        lambda {
          @valid_params.delete(:email)
          @auth.zendesk_remote_auth_url(@valid_params)
        }.should raise_error(ArgumentError) 
      end

    end
    
    it 'should return a url that starts with the auth_url' do
      @auth.zendesk_remote_auth_url(@valid_params)
    end

    it 'should have a hash param' do
      @auth.zendesk_remote_auth_url(@valid_params).should_not =~ /hash=(&|$)/
    end

    it 'should have a different hash param if external_id and remote_photo_url provided ' do
      a=@auth.zendesk_remote_auth_url(@valid_params.merge(:external_id => 'id')).match(/(hash=[^&]*)/)[1]
      b=@auth.zendesk_remote_auth_url(@valid_params.merge(:external_id => 'id', :remote_photo_url => 'photo_url')).match(/(hash=[^&]*)/)[1]
      a.should_not == b
    end

    context 'given a user object' do
      before(:each) do
        @user = mock
        @user.should_receive(:name).and_return('a_name')
        @user.should_receive(:email).and_return('an_email')
      end
      
      it 'should pull the name from the user' do
        @auth.zendesk_remote_auth_url(@user).should =~ /name=a_name/
      end
      
      it 'should pull the email from the user' do
        @auth.zendesk_remote_auth_url(@user).should =~ /email=an_email/
      end
      
      it 'should pull the id from the user' do
        @user.should_receive(:id).and_return('an_id')
        @auth.zendesk_remote_auth_url(@user).should =~ /external_id=an_id/
      end

      it 'should pull the organization from the user if available' do
        @user.should_receive(:zendesk_organization).and_return('org')
        @auth.zendesk_remote_auth_url(@user).should =~ /organization=org/
      end
      
      it 'should pull tags from the user if available' do
        @user.should_receive(:zendesk_tags).and_return('fine looking gentlemen,married')
        @auth.zendesk_remote_auth_url(@user).should =~/tags=fine\+looking\+gentlemen%2Cmarried/
      end
    end
  end
end
