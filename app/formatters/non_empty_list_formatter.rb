module NonEmptyListFormatter
  def format_non_empty_list
    ->values {
      case values
        when Array then Right.new format(values)
        else Left.new "Unable to format"
      end
    }
  end

  private
  include NonEmptyValidator

  def format values
    values.
      map {|a| validate_non_empty.(a)}.
      select {|a| Right == a.class}.
      map {|a| a.fold ->_ {},->r {r}}
  end
end
