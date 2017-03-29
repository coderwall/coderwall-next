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

  test "create protip" do
    sign_in
    post :create, params: { protip: {editable_tags: %w[socker duby], body: 'Hey there', title: 'First!'} }
    assert_response :success
  end

  test "don't show bad content to signed out users" do
    create(:protip, bad_content: true)
    get :index
    assert_response :success
  end
end
