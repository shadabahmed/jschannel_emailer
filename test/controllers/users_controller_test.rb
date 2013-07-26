require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @user = users(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user" do
    assert_difference('User.count') do
      post :create, user: { avatar_url: @user.avatar_url, followers_url: @user.followers_url, following_url: @user.following_url, github_id: @user.github_id, html_url: @user.html_url, login: @user.login, organizations_url: @user.organizations_url, repos_url: @user.repos_url, starred_url: @user.starred_url, type: @user.type, url: @user.url }
    end

    assert_redirected_to user_path(assigns(:user))
  end

  test "should show user" do
    get :show, id: @user
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user
    assert_response :success
  end

  test "should update user" do
    patch :update, id: @user, user: { avatar_url: @user.avatar_url, followers_url: @user.followers_url, following_url: @user.following_url, github_id: @user.github_id, html_url: @user.html_url, login: @user.login, organizations_url: @user.organizations_url, repos_url: @user.repos_url, starred_url: @user.starred_url, type: @user.type, url: @user.url }
    assert_redirected_to user_path(assigns(:user))
  end

  test "should destroy user" do
    assert_difference('User.count', -1) do
      delete :destroy, id: @user
    end

    assert_redirected_to users_path
  end
end
