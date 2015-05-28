module PivotTable
  class Grid
    include DataAccessor

    attr_accessor :source_data, :row_name, :column_name, :value_name, :field_name
    attr_reader :columns, :rows, :data_grid, :configuration, :access_method

    DEFAULT_OPTIONS = {
      :sort => true
    }

    def initialize(opts = {}, &block)
      yield(self) if block_given?
      @configuration = Configuration.new(DEFAULT_OPTIONS.merge(opts))
    end

    def build
      populate_grid
      build_rows
      build_columns
      self
    end

    def build_rows
      @rows = []
      @data_grid.each_with_index do |data, index|
        @rows << Row.new(
          :header             => row_headers[index],
          :data               => data,
          :value_name         => value_name,
          :orthogonal_headers => column_headers,
          :access_method      => access_method
        )
      end
    end

    def build_columns
      @columns = []
      @data_grid.transpose.each_with_index do |data, index|
        @columns << Column.new(
          :header             => column_headers[index],
          :data               => data,
          :value_name         => value_name,
          :orthogonal_headers => row_headers,
          :access_method      => access_method
        )
      end
    end

    def column_headers
      headers @column_name
    end

    def row_headers
      headers @row_name
    end

    def column_totals
      columns.map { |c| c.total }
    end

    def row_totals
      rows.map { |r| r.total }
    end

    def grand_total
      column_totals.inject(0) { |t, x| t + x }
    end

    def prepare_grid
      @data_grid = []
      row_headers.count.times do
        @data_grid << column_headers.count.times.inject([]) { |col| col << nil }
      end
      @data_grid
    end

    def populate_grid
      determine_access_method
      prepare_grid
      row_headers.each_with_index do |row, row_index|
        current_row = []
        column_headers.each_with_index do |col, col_index|
          object = @source_data.find { |item| access_record(item, row_name) == row && access_record(item, column_name) == col }
          current_row[col_index] = field_name ? access_record(object, field_name) : object
        end
        @data_grid[row_index] = current_row
      end
      @data_grid
    end

    private

    def headers(key)
      hdrs = @source_data.collect { |c| access_record(c, key) }.uniq
      configuration.sort ? hdrs.sort : hdrs
    end

  end
end
