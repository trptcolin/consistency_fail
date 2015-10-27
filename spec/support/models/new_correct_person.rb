class NewCorrectPerson < CorrectPerson
  self.table_name = 'new_correct_people'

  def readonly?
    true
  end
end
