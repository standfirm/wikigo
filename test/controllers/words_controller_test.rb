require 'test_helper'

class WordsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users( :john ) 
    sign_in(@user)

    @word = words(:one)
  end

  test "個別記事が表示できる" do
    get word_url(@word)
    assert_response :success
  end

  test "単語一覧ページへのアクセスができる" do
    get words_index_url
    assert_response :success
  end

  test "記事作成ページにアクセスできる" do
    get new_word_url
    assert_response :success
  end

  test "記事が作成できる" do
    assert_difference('Word.count') do
      post words_url, params: { word: { body: @word.body, title: @word.title + "_different_title" } }
    end

    assert_redirected_to word_url(Word.last)
  end

  test "記事を作成するとfavoriteが付いている" do
    post words_url, params: { word: { body: '', title: 'fav-test' } }
    @word = Word.find_by_title('fav-test')
    assert_equal 1, @word.favorites.count
  end

  test "記事の編集ページが表示できる" do
    get edit_word_url(@word)
    assert_response :success
  end

  test "記事の編集ができる" do
    patch word_url(@word), params: { word: { body: @word.body, title: @word.title } }
    assert_redirected_to word_url(@word)
  end
end
