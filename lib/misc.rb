class Enumerator
  def more?
    begin
      self.peek
      true
    rescue
      false
    end
  end
end