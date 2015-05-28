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
      @column_headers ||= headers @column_name
    end

    def row_headers
      @row_headers ||= headers @row_name
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
      @data_grid = Array.new(row_headers.size) { Array.new(column_headers.size) }
    end

    def populate_grid
      determine_access_method
      prepare_grid

      row_header_indices = index_map(row_headers)
      column_header_indices = index_map(column_headers)

      @source_data.each do |item|
        row_index = row_header_indices[access_record(item, row_name)]
        column_index = column_header_indices[access_record(item, column_name)]
        @data_grid[row_index][column_index] = field_name ? access_record(item, field_name) : item
      end

      @data_grid
    end

    private

    def headers(key)
      hdrs = @source_data.collect { |c| access_record(c, key) }.uniq
      configuration.sort ? hdrs.sort : hdrs
    end

    # Returns a mapping from array item to array index (for quick lookups
    # instead of using Array#index). Only works for arrays that have unique
    # item sets.
    def index_map(array)
      map = {}
      array.each_with_index { |array_item, index| map[array_item] = index }
      map
    end

  end
end
