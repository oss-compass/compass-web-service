require 'yaml'
require 'json'
require 'fileutils'

input_directory = File.join(__dir__, '../i18n')
output_directory = File.join(__dir__, '../config/locales')

response = Dir.glob(File.join(input_directory, '**/*.json')).reduce({}) do |result, file_path|
  dir = File.basename(File.dirname(file_path))
  file = File.basename(file_path, '.json')
  dir = 'zh-CN' if dir == 'zh'
  result[dir] ||= {}
  result[dir][file] = JSON.parse(File.read(file_path))
  result
end.map do |key, content|
  File.open(File.join(output_directory, "#{key}.yml"), 'w') do |file|
    file.write(YAML.dump({ key => content}).gsub("---\n", ''))
  end
end

puts response
