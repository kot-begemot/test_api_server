require 'test_helper'

class VideoTest < ActiveSupport::TestCase

  setup do
    @video = Video.create url: "http://www.youtube.com/embed/diDLgFvq7bo"
  end

  test "Mailfirmed urls" do
    %w{file://fancy.path}.each do |url|
      v = Video.create url: url
      assert v.new?
      assert !v.errors.get(:url).blank?
    end
  end

  test "Creation" do
    assert @video.persisted?
  end

  test "Initialize downloading" do
    assert_equal 'new', @video.state
    @video.stubs(:download_url).returns(true)
    @video.download!
    assert_equal 'downloading', @video.reload.state
  end

  test "Change state after downloading" do
    assert_equal 'new', @video.state
    assert_nil @video.downloaded_at
    @video.download!
    assert_equal 'downloaded', @video.reload.state
    assert_not_nil @video.downloaded_at
  end

  test "Initialize processing" do
    @video.download!
    assert_equal 'downloaded', @video.reload.state

    @video.stubs(:start_conversion).returns(true)
    @video.process!
    assert_equal 'processing', @video.reload.state
  end

  test "Change state after processing" do
    @video.download!
    assert_equal 'downloaded', @video.reload.state
    assert_nil @video.processed_at

    @video.process!
    assert_equal 'finished', @video.reload.state
    assert_not_nil @video.processed_at
  end

  test "Download and process assyncronously" do
    Delayed::Worker.new.work_off
    assert_equal 0, Delayed::Job.count

    @video.delay.download_and_convert

    assert_equal 1, Delayed::Job.count
    Delayed::Worker.new.work_off

    @video.reload

    assert_equal 'finished', @video.state
    assert_equal 0, Delayed::Job.count
  end

end