require 'test_helper'

class VideosControllerTest < ActionController::TestCase
  setup do
    @video = videos(:valid)
    Video.any_instance.stubs(:process_emulation).with(any_parameters).returns(true)
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

  test "Should show conversation is finished" do
    assert_equal 'new', @video.state
    @video.state = 'processed'
    @video.save

    visit "/videos/#{@video.id}.json"
    expected_content = "{\"video\":{\"id\":#{@video.id},\"state\":\"processed\"}}"
    assert page.has_content?(expected_content), "Page content was:\n#{page.source}\nExpected: #{expected_content}"
  end

  test "Should show storing is not finished" do
    assert_equal 'new', @video.state
    @video.state = 'storing'
    @video.progress = 42.15
    @video.save

    visit "/videos/#{@video.id}.json"
    expected_content = "{\"video\":{\"id\":#{@video.id},\"state\":\"storing\",\"progress\":42.15}}"
    assert page.has_content?(expected_content), "Page content was:\n#{page.source}\nExpected: #{expected_content}"
  end

  test "Should show details if finished" do
    assert_equal 'new', @video.state
    @video.download! && @video.process! && @video.store!

    visit "/videos/#{@video.id}.json"
    expected_content = "{\"video\":{\"id\":#{@video.id},\"finished_at\":\"#{@video.finished_at.iso8601}\",\"resolution\":\"800x600\",\"fps\":#{@video.fps},\"video_info\":\"#{@video.resolution} (2.37:1), #{@video.fps} fps, XviD build 50 ~1760 kbps avg, 0.34 bit/pixel\",\"audio_info\":\"48 kHz, AC3 Dolby Digital, 3/2 (L,C,R,l,r) + LFE ch, ~384 kbps\",\"duration\":\"#{Time.at(@video.duration ).utc.strftime("%T")}\"}}"
    assert page.has_content?(expected_content), "Page content was:\n#{page.source}\nExpected: #{expected_content}"
  end

end
