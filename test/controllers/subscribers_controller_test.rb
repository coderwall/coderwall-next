require 'test_helper'

class SubscribersControllerTest < ActionController::TestCase
  test "create" do
    subscriber = create(:user)
    protip = create(:protip)
    sign_in_as subscriber

    assert_difference ->{ protip.reload.subscribers.size }, 1 do
      post :create, protip_id: protip.public_id, format: :json
    end

    assert_includes assigns(:protip).subscribers, subscriber.id
  end

  test "destroy" do
    subscriber = create(:user)
    protip = create(:protip, subscribers: [subscriber.id])

    sign_in_as subscriber

    assert_difference ->{ protip.reload.subscribers.size }, -1 do
      delete :destroy, protip_id: protip.public_id, format: :json
    end

    assert_not_includes assigns(:protip).subscribers, subscriber.id
  end
end
