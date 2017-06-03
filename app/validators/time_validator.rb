class TimeValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    return true if value.kind_of?(Time)
    record.errors[attribute] << I18n.t('errors.messages.invalid_time_format') unless /\A\d{1,2}\:\d{1,2}\Z/ =~ value.to_s

    begin
      (hh,mm) = value.split(':')
      Time.local(0, 0, 0, hh, mm, 0)
    rescue
      record.errors[attribute] << I18n.t('errors.messages.invalid_time')
    end
  end

end
