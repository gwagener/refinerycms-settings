require 'spec_helper'

module Refinery
  describe Setting do

    before do
      ::Refinery::Setting.set(:creating_from_scratch, nil)
      ::Refinery::Setting.set(:rspec_testing_creating_from_scratch, nil)
    end

    context "slug" do
      it "should create correct slug" do
        ::Refinery::Setting.set('test/something', {:value => "Look, a value"})
        ::Refinery::Setting.last.to_param.should eq('test-something')
      end
    end

    context "set" do
      it "should save and get @keram" do
        ::Refinery::Setting.find_or_set(:twitter, '@keram')
        setting = ::Refinery::Setting.last
        setting.value.should eq('@keram')
      end

      it "should not strip whitespaces" do
        ::Refinery::Setting.find_or_set(:author, ' benbruscella ')
        setting = ::Refinery::Setting.last
        setting.value.should eq(' benbruscella ')
      end

      it "should create a setting that didn't exist" do
        ::Refinery::Setting.get(:creating_from_scratch, :scoping => 'rspec_testing').should eq(nil)
        ::Refinery::Setting.set(:creating_from_scratch, {:value => "Look, a value", :scoping => 'rspec_testing'}).should eq("Look, a value")
      end

      it "should override an existing setting" do
        set = ::Refinery::Setting.set(:creating_from_scratch, {:value => "a value", :scoping => 'rspec_testing'})
        set.should eq("a value")

        new_set = ::Refinery::Setting.set(:creating_from_scratch, {:value => "newer replaced value", :scoping => 'rspec_testing'})
        new_set.should eq("newer replaced value")
      end

      it "should default to form_value_type text_area" do
        set = ::Refinery::Setting.set(:creating_from_scratch, {:value => "a value", :scoping => 'rspec_testing'})
        ::Refinery::Setting.find_by(:name => 'creating_from_scratch', :scoping => 'rspec_testing').form_value_type.should eq("text_area")
      end

      it "should fix true as a value to 'true' (string)" do
        set = ::Refinery::Setting.set(:creating_from_scratch, {:value => true, :scoping => 'rspec_testing'})
        ::Refinery::Setting.find_by(:name => 'creating_from_scratch', :scoping => 'rspec_testing')[:value].should eq('true')
        set.should eq(true)
      end

      it "should fix false as a value to 'false' (string)" do
        set = ::Refinery::Setting.set(:creating_from_scratch, {:value => false, :scoping => 'rspec_testing'})
        ::Refinery::Setting.find_by(:name => 'creating_from_scratch', :scoping => 'rspec_testing')[:value].should eq('false')
        set.should eq(false)
      end

      it "should fix '1' as a value with a check_box form_value_type to true" do
        set = ::Refinery::Setting.set(:creating_from_scratch, {:value => "1", :scoping => 'rspec_testing', :form_value_type => 'check_box'})
        ::Refinery::Setting.find_by(:name => 'creating_from_scratch', :scoping => 'rspec_testing')[:value].should eq('true')
        set.should eq(true)
      end

      it "should fix '0' as a value with a check_box form_value_type to false" do
        set = ::Refinery::Setting.set(:creating_from_scratch, {:value => "0", :scoping => 'rspec_testing', :form_value_type => 'check_box'})
        ::Refinery::Setting.find_by(:name => 'creating_from_scratch', :scoping => 'rspec_testing')[:value].should eq('false')
        set.should eq(false)
      end
    end

    context "get" do
      it "should retrieve a seting that was created" do
        set = ::Refinery::Setting.set(:creating_from_scratch, {:value => "some value", :scoping => 'rspec_testing'})
        set.should eq('some value')

        get = ::Refinery::Setting.get(:creating_from_scratch, :scoping => 'rspec_testing')
        get.should eq('some value')
      end

      it "should also work with setting scoping using string and getting via symbol" do
        set = ::Refinery::Setting.set(:creating_from_scratch, {:value => "some value", :scoping => 'rspec_testing'})
        set.should eq('some value')

        get = ::Refinery::Setting.get(:creating_from_scratch, :scoping => :rspec_testing)
        get.should eq('some value')
      end

      it "should also work with setting scoping using symbol and getting via string" do
        set = ::Refinery::Setting.set(:creating_from_scratch, {:value => "some value", :scoping => :rspec_testing})
        set.should eq('some value')

        get = ::Refinery::Setting.get(:creating_from_scratch, :scoping => 'rspec_testing')
        get.should eq('some value')
      end
    end

    context "find_or_set" do
      it "should create a non existant setting" do
        created = ::Refinery::Setting.find_or_set(:creating_from_scratch, 'I am a setting being created', :scoping => 'rspec_testing')

        created.should eq("I am a setting being created")
      end

      it "should not override an existing setting" do
        created = ::Refinery::Setting.set(:creating_from_scratch, {:value => 'I am a setting being created', :scoping => 'rspec_testing'})
        created.should eq("I am a setting being created")

        find_or_set_created = ::Refinery::Setting.find_or_set(:creating_from_scratch, 'Trying to change an existing value', :scoping => 'rspec_testing')

        created.should eq("I am a setting being created")
      end

      it "should work without scoping" do
        ::Refinery::Setting.find_or_set(:rspec_testing_creating_from_scratch, 'Yes it worked').should eq('Yes it worked')
      end
    end

    describe "#should_generate_new_friendly_id?" do
      context "when name changes" do
        it "regenerates slug upon save" do
          setting = FactoryGirl.create(:setting, :name => "Test Name")

          setting.name = "Test Name 2"
          setting.save!

          expect(setting.slug).to eq("test-name-2")
        end
      end
    end
  end
end
