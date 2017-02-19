require 'test_helper'

class SubscribersControllerTest < ActionController::TestCase
  test "create" do
    subscriber = create(:user)
    protip = create(:protip)
    sign_in_as subscriber

    assert_difference ->{ protip.reload.subscribers.size }, 1 do
      post :create, params: { protip_id: protip.id, format: :json }
    end

    assert_includes assigns(:protip).subscribers, subscriber.id
  end

  test "destroy" do
    subscriber = create(:user)
    protip = create(:protip, subscribers: [subscriber.id])

    sign_in_as subscriber

    assert_difference ->{ protip.reload.subscribers.size }, -1 do
      delete :destroy, params: { protip_id: protip.id, format: :json }
    end

    assert_not_includes assigns(:protip).subscribers, subscriber.id
  end
end
