# -*- coding: utf-8 -*-

require 'pocket_miku'

Plugin.create(:pocket_miku) do
  notify_thread = SerialThreadGroup.new

  settings "ポケット・ミク" do
    fileselect 'midiデバイス', :pocket_miku_device, '/dev/'

    sound_test_button = Gtk::Button.new('発音テスト')
    closeup sound_test_button.right

	boolean 'ふぁぼ通知', :pocket_miku_fav_notification

    sound_test_button.signal_connect('clicked') do
      # 調教的にキツい
      sing do
        tempo 140
        み key: 72, length: PocketMiku::Note16
        く key: 76, length: PocketMiku::Note16
        っ PocketMiku::Note8
        た key: 72, length: PocketMiku::Note4
      end
    end end

  on_favorite do |service, by, to|
    if UserConfig[:pocket_miku_fav_notification] and to.from_me?
      notify_thread.new do
        sing do
          tempo 140
          ふぁ key: 75, length: PocketMiku::Note16
          ぼ key: 82, length: PocketMiku::Note16
        end end end end

  device_watcher = UserConfig.connect(:pocket_miku_device) do
    pocket_miku_reset end

  on_unload do
    pocket_miku_reset
    UserConfig.disconnect(device_watcher) end

  at_exit do
    pocket_miku_reset end

  def sing
    if pocket_miku
      pocket_miku.sing(&Proc.new) end
  rescue => exception
    error exception
    pocket_miku_reset end

  def pocket_miku
    return nil unless UserConfig[:pocket_miku_device]
    atomic do
      if not(@pocket_miku) or @pocket_miku.closed?
        @pocket_miku = PocketMiku::Device.new(UserConfig[:pocket_miku_device]) end end
    @pocket_miku
  rescue => exception
    error exception
    @pocket_miku = nil end

  def pocket_miku_reset
    atomic do
      if @pocket_miku
        @pocket_miku.stop.close rescue nil end
      @pocket_miku = nil end end

end


