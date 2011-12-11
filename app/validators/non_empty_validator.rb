module NonEmptyValidator
  def validate_non_empty
    ->value {
      if value.nil? or /\A[[:space:]]*\Z/.match value then Left.new "Value is invalid"
      else Right.new value end
    }
  end
end
