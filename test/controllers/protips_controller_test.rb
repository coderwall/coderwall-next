require 'test_helper'

class ProtipsControllerTest < ActionController::TestCase
  test "show signed in" do
    protip = create(:protip)
    sign_in
    get :show, params: { id: protip.public_id, slug: protip.slug }
    assert_response :success
  end

  test "show signed out" do
    protip = create(:protip)
    get :show, params: { id: protip.public_id, slug: protip.slug }
    assert_response :success
  end
end
