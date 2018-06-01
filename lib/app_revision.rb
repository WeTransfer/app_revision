require "app_revision/version"

# Returns the current application git commit SHA. Will look first in the APP_REVISION
# environment variable, then in the REVISION file written by Capsitrano, then
# in the Git history and lastly will return 'unknown' will be returned
module AppRevision
  ENV_VARS = [
    'APP_REVISION', # As used by Appsignal et al
    'HEROKU_SLUG_COMMIT', # As is available in https://devcenter.heroku.com/articles/dyno-metadata
    'SOURCE_VERSION', # As defined in https://devcenter.heroku.com/changelog-items/630
    'TRAVIS_COMMIT', # As per https://docs.travis-ci.com/user/environment-variables/
  ]

  # Calls `determine_current` with memoization.
  def self.current
    @current ||= determine_current
  end

  # Performs version detection in the following order:
  # APP_REVISION -> REVISION file -> git -> "unknown"
  # and returns the current commit/revision SHA as a String
  def self.determine_current
    detected_rev_str = read_from_env || read_from_revision_file || determine_from_git_rev || unknown_revision
    up_to_newline(detected_rev_str)
  end

  private

  def self.up_to_newline(str)
    str.scan(/[a-z0-9\-]+/)[0]
  end

  def self.unknown_revision
    'unknown'
  end
  
  def self.determine_from_git_rev
    cmd_output = `git rev-parse --verify HEAD`.strip
    return cmd_output if cmd_output =~ /^[a-f\d]{40}$/
  end

  def self.read_from_env
    ENV_VARS.each do |envvar|
      envvar_value = ENV.fetch(envvar, '').strip
      return envvar_value unless envvar_value.empty?
    end
    nil
  end

  def self.read_from_revision_file
    search_path = Rails.root.to_s if defined?(Rails.root)
    search_path ||= Dir.pwd

    path_components = File.split(File.expand_path(search_path))
    begin
      File.read(File.join(path_components + ['REVISION'])).chomp
    rescue Errno::ENOENT
      if path_components.empty?
        return nil
      else
        path_components.pop # Remove the last path part and try again
        retry
      end
    end
  end
end
