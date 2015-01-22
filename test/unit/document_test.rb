require 'test_helper'

describe LivingStyleGuide::Document do

  before do
    @doc = LivingStyleGuide::Document.new('')
  end

  def assert_document_equals(input, output)
    @doc.source = input.gsub(/^        /, '')
    actual = @doc.render.gsub(/\n\n+/, "\n").strip
    expected = output.gsub(/^        /, '').gsub(/\n\n+/, "\n").strip
    actual.must_equal expected
  end

  describe "base features" do

    it "outputs the source" do
      doc = LivingStyleGuide::Document.new("Test")
      doc.source.must_equal "Test"
    end

    it "outputs the input as default" do
      assert_document_equals "Test", "Test"
    end

    it "outputs the input as HTML for Markdown" do
      @doc.type = :markdown
      assert_document_equals <<-INPUT, <<-OUTPUT
        *Test*
      INPUT
        <p class="livingstyleguide--paragraph"><em>Test</em></p>
      OUTPUT
    end

  end

  describe "change type by filter" do

    it "allows to set the type to Markdown" do
      assert_document_equals <<-INPUT, <<-OUTPUT
        @markdown
        *Test*
      INPUT
        <p class="livingstyleguide--paragraph"><em>Test</em></p>
      OUTPUT
    end

    it "allows to set the type to Haml" do
      assert_document_equals <<-INPUT, <<-OUTPUT
        @haml
        %test Test
      INPUT
        <test>Test</test>
      OUTPUT
    end

    it "allows to set the type to Coffee-Script" do
      assert_document_equals <<-INPUT, <<-OUTPUT
        @coffee-script
        alert "Test"
      INPUT
        (function() {
          alert("Test");
        }).call(this);
      OUTPUT
    end

    it "allows to set the type to Coffee-Script with short version" do
      assert_document_equals <<-INPUT, <<-OUTPUT
        @coffee
        alert "Test"
      INPUT
        (function() {
          alert("Test");
        }).call(this);
      OUTPUT
    end

  end

  describe "filter syntax" do

    it "can have filters with an argument" do
      LivingStyleGuide::Filters.add_filter :my_filter do |arg|
        "arg: #{arg}"
      end
      assert_document_equals <<-INPUT, <<-OUTPUT
        @my-filter Test
        Lorem ipsum
      INPUT
        arg: Test
        Lorem ipsum
      OUTPUT
    end

    it "can have filters with multiple arguments" do
      LivingStyleGuide::Filters.add_filter :my_second_filter do |arg1, arg2|
        "arg1: #{arg1}\narg2: #{arg2}"
      end
      assert_document_equals <<-INPUT, <<-OUTPUT
        @my-second-filter Test, More test
        Lorem ipsum
      INPUT
        arg1: Test
        arg2: More test
        Lorem ipsum
      OUTPUT
    end

    it "can have filters with a block" do
      LivingStyleGuide::Filters.add_filter :x do |block|
        block.gsub(/\w/, 'X')
      end
      assert_document_equals <<-INPUT, <<-OUTPUT
        @x {
          Lorem ipsum
          dolor
        }
        Lorem ipsum
      INPUT
        XXXXX XXXXX
        XXXXX
        Lorem ipsum
      OUTPUT
    end

    it "can have filters with multiple arguments and a block" do
      LivingStyleGuide::Filters.add_filter :y do |arg1, arg2, block|
        "arg1: #{arg1}\narg2: #{arg2}\n#{block.gsub(/\w/, 'Y')}"
      end
      assert_document_equals <<-INPUT, <<-OUTPUT
        @y 1, 2 {
          Lorem ipsum
          dolor
        }
        Lorem ipsum
      INPUT
        arg1: 1
        arg2: 2
        YYYYY YYYYY
        YYYYY
        Lorem ipsum
      OUTPUT
    end

    it "blocks should allow CSS (nested {})" do
      LivingStyleGuide::Filters.add_filter :css_test do |block|
        block
      end
      assert_document_equals <<-INPUT, <<-OUTPUT
        @css-test {
          .my-class {
            background: black;
            &:hover {
              background: red;
            }
          }
        }
        Lorem ipsum
      INPUT
        .my-class {
          background: black;
          &:hover {
            background: red;
          }
        }
        Lorem ipsum
      OUTPUT
    end

    it "can have filters with an indented block" do
      LivingStyleGuide::Filters.add_filter :x_indented do |block|
        block.gsub(/\w/, 'X')
      end
      assert_document_equals <<-INPUT, <<-OUTPUT
        @x-indented
          Lorem ipsum
          dolor
        Lorem ipsum
      INPUT
        XXXXX XXXXX
        XXXXX
        Lorem ipsum
      OUTPUT
    end

    it "can have filters with multiple arguments and an indented block" do
      LivingStyleGuide::Filters.add_filter :y_indented do |arg1, arg2, block|
        "arg1: #{arg1}\narg2: #{arg2}\n#{block.gsub(/\w/, 'Y')}"
      end
      assert_document_equals <<-INPUT, <<-OUTPUT
        @y-indented 1, 2
          Lorem ipsum
          dolor
        Lorem ipsum
      INPUT
        arg1: 1
        arg2: 2
        YYYYY YYYYY
        YYYYY
        Lorem ipsum
      OUTPUT
    end

    it "blocks should allow indented CSS (nested {})" do
      LivingStyleGuide::Filters.add_filter :css_test_indented do |block|
        block
      end
      assert_document_equals <<-INPUT, <<-OUTPUT
        @css-test-indented
          .my-class
            background: black
            &:hover
              background: red
        Lorem ipsum
      INPUT
        .my-class
          background: black
          &:hover
            background: red
        Lorem ipsum
      OUTPUT
    end

  end

  describe "templates" do

    it "should use template" do
      @doc.template = 'my-template'
      File.stub :read, "*<%= html %>*" do
        assert_document_equals "Test", "*Test*"
      end
    end

  end
end