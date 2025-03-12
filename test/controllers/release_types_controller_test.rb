require "test_helper"

class ReleaseTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @release_type = release_types(:one)
  end

  test "should get index" do
    get release_types_url
    assert_response :success
  end

  test "should get new" do
    get new_release_type_url
    assert_response :success
  end

  test "should create release_type" do
    assert_difference("ReleaseType.count") do
      post release_types_url, params: { release_type: { name: @release_type.name } }
    end

    assert_redirected_to release_type_url(ReleaseType.last)
  end

  test "should show release_type" do
    get release_type_url(@release_type)
    assert_response :success
  end

  test "should get edit" do
    get edit_release_type_url(@release_type)
    assert_response :success
  end

  test "should update release_type" do
    patch release_type_url(@release_type), params: { release_type: { name: @release_type.name } }
    assert_redirected_to release_type_url(@release_type)
  end

  test "should destroy release_type" do
    assert_difference("ReleaseType.count", -1) do
      delete release_type_url(@release_type)
    end

    assert_redirected_to release_types_url
  end
end
