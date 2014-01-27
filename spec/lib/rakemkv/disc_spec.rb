require 'spec_helper'

describe RakeMKV::Disc do
  before do
    allow_any_instance_of(RakeMKV::Command).to receive(:info) { RakeMKVMock.info }
  end

  describe '#new' do
    it 'accepts the device path' do
      RakeMKV::Disc.new('/dev/sd0').path.should eq 'dev:/dev/sd0'
    end
    it 'accepts the file iso path' do
      RakeMKV::Disc.new('path_to.iso').path.should eq 'iso:path_to.iso'
    end
    it 'accepts disc parameter' do
      RakeMKV::Disc.new('disc:0').path.should eq 'disc:0'
    end
    it 'accepts an integer for the path' do
      RakeMKV::Disc.new(0).path.should eq 'disc:0'
    end
    it 'raises an error when not a valid path' do
      expect { RakeMKV::Disc.new('bork') }.to raise_error
    end
    it 'gets the info about the disk' do
      expect_any_instance_of(RakeMKV::Command).to receive(:info)
      RakeMKV::Disc.new('disc:0')
    end
    it 'parses the info into something more usable' do
      expect(RakeMKV::Parser).to receive(:new).and_call_original
      RakeMKV::Disc.new('disc:0')
    end
  end

  describe '#type' do
    subject(:disc) { RakeMKV::Disc.new('disc:0') }
    it 'finds the disc type' do
      expect(disc.type).to eq 'DVD disc'
    end
  end

  describe '#transcode!' do
    subject(:disc) { RakeMKV::Disc.new('disc:0') }
    let(:title) { double(RakeMKV::Title, id: 0, time: 1222) }
    before { File.stub(:directory?).and_return true }

    it 'errors when destination does not exist' do
      disc.stub(:titles).and_return [title]
      File.stub(:directory?).and_return false
      expect { disc.transcode!('/path/to/heart/') }.to raise_error
    end

    it 'accepts destination' do
      disc.stub(:titles).and_return [title]
      expect_any_instance_of(RakeMKV::Command).to receive(:mkv)
        .with(0, '/path/to/heart/').at_least(:once)
      disc.transcode!('/path/to/heart/')
    end

    it 'converts titles based on time' do
      title2 = double(RakeMKV::Title, id: 1, time: 1000)
      disc.stub(:titles).and_return [title2, title]
      expect_any_instance_of(RakeMKV::Command).to receive(:mkv)
        .with(0, '/path/to/heart/')
      disc.transcode!('/path/to/heart/')
    end

    it 'converts only a specific title' do
      title2 = double(RakeMKV::Title, id: 1, time: 1000)
      disc.stub(:titles).and_return [title2, title]
      expect_any_instance_of(RakeMKV::Command).to receive(:mkv)
        .with(0, '/path/to/heart/')
      disc.transcode!('/path/to/heart/', 0)
    end
  end

  describe '#name' do
    subject(:disc) { RakeMKV::Disc.new('disc:0') }
    it 'grabs the name of the disc' do
      expect(disc.name).to eq 'DIME_NTSC'
    end
  end

  describe '.discs' do
    it 'checks all discs' do
      expect_any_instance_of(RakeMKV::Command).to receive(:info)
      RakeMKV::Disc.discs
    end
  end
end
