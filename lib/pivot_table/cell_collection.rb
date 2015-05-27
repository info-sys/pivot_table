module PivotTable
  module CellCollection

    ACCESSORS = [:header, :data, :value_name, :orthogonal_headers, :access_method]

    ACCESSORS.each do |a|
      self.send(:attr_accessor, a)
    end

    def initialize(options = {})
      ACCESSORS.each do |a|
        self.send("#{a}=", options[a]) if options.has_key?(a)
      end
    end

    def total
      data.inject(0) { |t, x| t + (x ? access_record(x, value_name) : 0) }
    end

  private

    def find_data by_header_name
      data[
        orthogonal_headers.find_index{|header| by_header_name.to_s == header.to_s}
      ] rescue nil
    end

    def access_record(item, key)
      if access_method == :hash
        item[key]
      else
        item.send(key)
      end
    end

  end
end
