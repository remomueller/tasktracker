module TaskTracker
  module VERSION #:nodoc:
    MAJOR = 0
    MINOR = 28
    TINY = 11
    BUILD = 'pre' # 'pre', 'beta1', 'beta2', 'rc', 'rc2', nil

    STRING = [MAJOR, MINOR, TINY, BUILD].compact.join('.')
  end
end
