i = 1

authors = [['Author', 'DocumentID']]
documents = [['DocumentID', 'Text']]

Dir.new('raw_speeches_and_press_releases').entries.each do |path|
  next if path.match(/\.txt$/).nil?
  name, date, number = path.split(/_/)
  first_name, second_name = name.split(/-/)
  authors << [[first_name, second_name].join(" "), i]
  filename = File.expand_path(path, 'raw_speeches_and_press_releases')
  text = File.open(filename, 'r') {|f| f.read()}
  words = text.downcase.scan(/[\w]+/)
  documents << [i, words.join(" ")]
  i = i + 1
end

File.open('cache/documents.csv', 'w') do |f|
  f.puts documents.map {|document_info| document_info.join(",")}.join("\n")
end

File.open('cache/authors.csv', 'w') do |f|
  f.puts authors.map {|author_info| author_info.join(",")}.join("\n")
end
