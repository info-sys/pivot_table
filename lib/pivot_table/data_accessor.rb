module PivotTable
  module DataAccessor

    attr_accessor :access_method

    def determine_access_method
      @access_method = @source_data.first.kind_of?(Hash) ? :hash : :send
    end

    def access_record(item, key)
      case access_method
      when :hash then item[key]
      when :send then item.send(key)
      else raise ArgumentError, "Invalid access method: #{access_method}."
      end
    end

  end
end
