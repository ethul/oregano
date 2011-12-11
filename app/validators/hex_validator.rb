module HexValidator
  def validate_hex
    ->value {
      if value.nil? or /\A[[:xdigit:]]*\Z/.match value then Right.new value
      else Left.new "Value is invalid" end
    }
  end
end
