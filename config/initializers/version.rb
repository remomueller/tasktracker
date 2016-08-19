# frozen_string_literal: true

module TaskTracker
  module VERSION #:nodoc:
    MAJOR = 0
    MINOR = 30
    TINY = 0
    BUILD = 'beta5' # 'pre', 'beta1', 'beta2', 'rc', 'rc2', nil

    STRING = [MAJOR, MINOR, TINY, BUILD].compact.join('.').freeze
  end
end
