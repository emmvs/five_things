# frozen_string_literal: true

# Helper methods for HappyThing views
module HappyThingsHelper
  # Formats dates as 'Today', 'Yesterday', or 'Month Day' with an ordinal suffix
  def friendly_date(date)
    case (Date.current - date.to_date).to_i
    when 0
      'Today'
    when 1
      'Yesterday'
    else
      "#{date.strftime('%B %-d')}#{date.strftime('%d').to_i.ordinal}"
    end
  end
end
