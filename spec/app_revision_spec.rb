require 'tmpdir'
require 'tempfile'

RSpec.describe AppRevision do
  it "has a version number" do
    expect(AppRevision::VERSION).not_to be nil
  end

  before :each do
    @app_revision_location = AppRevision.method(:current).source_location[0]
  end

  before :each do
    AppRevision::ENV_VARS.each do |ev|
      ENV.delete(ev)
    end
  end

  it 'always provides a string value from .current' do
    expect(AppRevision.current).to be_kind_of(String)
  end

  it 'is set in the APP_REVISION environment variable on startup' do
    ENV['APP_REVISION'] = 'some-customized-rev'
    expect(AppRevision.determine_current).to eq('some-customized-rev')
    ENV.delete('APP_REVISION')
  end


  describe 'with each environment variable that can be used' do
    AppRevision::ENV_VARS.each do |ev|
      it "only uses the SHA component from #{ev} up to but excluding the newline" do
        ENV[ev] = "43ec44d89706ca948daea5124fdcc62694a87f43\na85f99a"
        expect(AppRevision.determine_current).to eq('43ec44d89706ca948daea5124fdcc62694a87f43')
        ENV.delete(ev)
      end

      it "does not use #{ev} if it is empty" do
        ENV[ev] = "   "
        expect(AppRevision.determine_current).not_to be_empty
        ENV.delete(ev)
      end
    end
  end

  it 'returns "unknown" if all version detection methods return nil' do
    expect(AppRevision).to receive(:read_from_env).and_return(nil)
    expect(AppRevision).to receive(:read_from_revision_file).and_return(nil)
    expect(AppRevision).to receive(:determine_from_git_rev).and_return(nil)

    expect(AppRevision.determine_current).to eq('unknown')
  end

  it 'returns the contents of the REVISION file relative to the current working directory' do
    cur = Dir.pwd
    tempdir = Dir.mktmpdir
    Dir.chdir(tempdir)
    written_git_ref = "zz43ec44d89706ca948daea5124fdcc62694a87f4\na85f99a"
    known_rev = "zz43ec44d89706ca948daea5124fdcc62694a87f4"

    # Write the file that AppRevisio will read
    File.open('REVISION', 'wb') {|f| f << written_git_ref }

    tf = Tempfile.new('readback')
    tf << AppRevision.determine_current
    tf.rewind

    expect(tf.read).to eq(known_rev)
    Dir.chdir(cur)
  end

  it 'returns the contents of the REVISION file relative to the app revsion location' do
    revision_file_path = File.dirname(File.dirname(@app_revision_location)) + "/REVISION"

    begin
      File.open(revision_file_path, "w") do |f|
        f << "43ec44d89706ca948daea5124fdcc62694a87f43\na85f99a"
      end
      expect(AppRevision.determine_current).to eq('43ec44d89706ca948daea5124fdcc62694a87f43')
    ensure
      File.unlink(revision_file_path)
    end
  end
end
