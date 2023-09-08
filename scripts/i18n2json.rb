require 'yaml'
require 'json'
require 'fileutils'

output_directory = File.join(__dir__, '../i18n')

response =
  [
    '../config/locales/zh-CN.yml',
    '../config/locales/en.yml'
  ].reduce({}) do |result, input_file|
  yaml = YAML.load_file(File.join(__dir__, input_file))
  result.merge(yaml)
end.map do |dir, mapping|
  dir = dir.slice(0, 2)
  target_dir = File.join(output_directory, dir)
  FileUtils.mkdir_p(target_dir)
  mapping.map do |file, content|
    file_path = File.join(target_dir, "#{file}.json")
    File.open(file_path, 'w') { |file| file.write(JSON.pretty_generate(content)) }
  end
end

puts response
