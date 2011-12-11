module Utf8Formatter
  def format_utf8
    ->value {
      begin
        Right.new(
          value.encode("utf-8",
            :invalid => :replace,
            :undef => :replace,
            :universal_newline => true
          )
        )
      rescue => e
        Left.new e
      end
    }
  end
end
