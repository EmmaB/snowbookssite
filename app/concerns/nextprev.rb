# -*- encoding : utf-8 -*-
module Nextprev
  # Defines the 'previous' record. The query argument passed in is an array from `session[:query] = @books.map(&:id)` in the controller index action
  # The `index` variable gets set to be the current record, then the previous record is set as the previous ID in the array.
  # The found order is thus preserved, so any sorting done by the user is maintained.
  def previous(query)
    unless query.nil?
      index = query.find_index(self.id)
      if index.nil?
      else
        prev_id = query[index-1] unless index.zero?
        self.class.find_by_id(prev_id)
      end
    end
  end

  def next(query)
    # Defines the 'next' record.
    unless query.nil?
      index = query.find_index(self.id)
      if index.nil?
      else
        next_id = query[index+1] unless index == query.size
        self.class.find_by_id(next_id)
      end
    end
  end





end

