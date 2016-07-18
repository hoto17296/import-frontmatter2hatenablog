require 'csv'

class ImagePathConverter
  def initialize(filepath)
    load(filepath)
  end

  def load(filepath)
    @list = {}
    CSV.foreach(filepath, :col_sep => "\t") do |row|
      data = { type: row[0], url: row[1], id: row[2], filename: row[3] }
      @list[data[:filename]] = data
    end
  end

  def [](filename)
    @list[filename]
  end
end
