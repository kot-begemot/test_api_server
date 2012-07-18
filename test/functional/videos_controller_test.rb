require 'test_helper'

class VideosControllerTest < ActionController::TestCase
  setup do
    @video = videos(:valid)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:videos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create video" do
    Delayed::Worker.new.work_off
    assert_equal 0, Delayed::Job.count
    assert_difference('Video.count') do
      post :create, video: @video.attributes
    end

    assert_redirected_to video_path(assigns(:video))
    assert_equal 1, Delayed::Job.count
  end

  test "should create video with json data" do
    Delayed::Worker.new.work_off
    assert_equal 0, Delayed::Job.count
    assert_difference('Video.count') do
      raw_post :create, {format: :json}, {url: "http://www.youtube.com/embed/diDLgFvq7bo"}.to_json
    end

    assert_response :created
    assert_equal 1, Delayed::Job.count
  end

  test "Should show recive request and proceed it asyncronously" do
    get :show, id: @video.to_param
    assert_response :success
  end
  
  test "Should show downloading is not finished" do
    assert_equal 'new', @video.state
    @video.state = 'downloading'
    @video.progress = 75.15
    @video.save

    visit "/videos/#{@video.id}.json"
    expected_content = "{\"video\":{\"id\":#{@video.id},\"state\":\"downloading\",\"progress\":75.15}}"
    assert page.has_content?(expected_content), "Page content was:\n#{page.source}\nExpected: #{expected_content}"
  end

  test "Should show downloading is finished" do
    assert_equal 'new', @video.state
    @video.state = 'downloaded'
    @video.save

    visit "/videos/#{@video.id}.json"
    expected_content = "{\"video\":{\"id\":#{@video.id},\"state\":\"downloaded\"}}"
    assert page.has_content?(expected_content), "Page content was:\n#{page.source}\nExpected: #{expected_content}"
  end

  test "Should show conversation is not finished" do
    assert_equal 'new', @video.state
    @video.state = 'processing'
    @video.progress = 12.15
    @video.save

    visit "/videos/#{@video.id}.json"
    expected_content = "{\"video\":{\"id\":#{@video.id},\"state\":\"processing\",\"progress\":12.15}}"
    assert page.has_content?(expected_content), "Page content was:\n#{page.source}\nExpected: #{expected_content}"
  end

  test "Should show details if finished" do
    assert_equal 'new', @video.state
    @video.download! && @video.process!

    visit "/videos/#{@video.id}.json"
    expected_content = "{\"video\":{\"id\":#{@video.id},\"state\":\"finished\",\"processed_at\":\"#{@video.processed_at.iso8601}\",\"downloaded_at\":\"#{@video.downloaded_at.iso8601}\"}}"
    assert page.has_content?(expected_content), "Page content was:\n#{page.source}\nExpected: #{expected_content}"
  end

end
