require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'
require 'json'
require 'yaml'
require 'open3'
require 'rbconfig'

class Json2I18nTest < Minitest::Test
  def test_preserves_document_markers_inside_translations
    translations = {
      'plain' => 'Hello',
      'multiline' => "Before\n---\nAfter\n---\n",
      'suffix' => "Before---\nAfter\n"
    }

    Dir.mktmpdir('json2i18n') do |directory|
      FileUtils.mkdir_p(File.join(directory, 'scripts'))
      FileUtils.mkdir_p(File.join(directory, 'i18n', 'en'))
      FileUtils.mkdir_p(File.join(directory, 'config', 'locales'))
      script = File.join(directory, 'scripts', 'json2i18n.rb')
      FileUtils.cp(File.expand_path('../../scripts/json2i18n.rb', __dir__), script)
      File.write(File.join(directory, 'i18n', 'en', 'example.json'), JSON.generate(translations))

      stdout, stderr, status = Open3.capture3(RbConfig.ruby, script)
      assert status.success?, "#{stdout}\n#{stderr}"
      output = File.read(File.join(directory, 'config', 'locales', 'en.yml'))
      refute output.start_with?("---\n")
      assert_equal translations, YAML.safe_load(output).fetch('en').fetch('example')
    end
  end
end
