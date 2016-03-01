# frozen_string_literal: true

module TaskTracker
  module VERSION #:nodoc:
    MAJOR = 0
    MINOR = 28
    TINY = 13
    BUILD = nil # 'pre', 'beta1', 'beta2', 'rc', 'rc2', nil

    STRING = [MAJOR, MINOR, TINY, BUILD].compact.join('.').freeze
  end
end
