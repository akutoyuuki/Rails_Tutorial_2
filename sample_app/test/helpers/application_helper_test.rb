require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
    #test "page title helper" do
    #    assert_equal page_title, "Ruby on Rails Tutorial Sample App"
    #end
    test "full title helper" do
        assert_equal full_title, "Ruby on Rails Tutorial Sample App"
        #assert_equal full_title("Help"), "Help | Ruby on Rails Tutorial Sample App"
    end
end