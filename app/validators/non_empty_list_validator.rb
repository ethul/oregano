module NonEmptyListValidator
  def validate_non_empty_list
    ->values {
      case values
      when Array then
        if values.nil? or values.empty? then Left.new "Values is invalid"
        else Right.new values end
      else Left.new "Values is invalid" end
    }
  end
end
