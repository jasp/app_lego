git :rm => "public/javascripts/*"

file 'public/javascripts/jquery.js', 
  open('http://code.jquery.com/jquery-latest.js').read
file 'public/javascripts/jquery.min.js', 
  open('http://code.jquery.com/jquery-latest.min.js').read

run "sudo gem install rubyzip"

require 'rubygems'
require 'zip/zip'

log "downloading", "jQuery UI 1.7" #http://code.google.com/p/jquery-ui/downloads/list
file('temp.zip', open('http://jquery-ui.googlecode.com/files/jquery-ui-1.7.zip').read)

#http://www.markhneedham.com/blog/2008/10/02/ruby-unzipping-a-file-using-rubyzip/
Zip::ZipFile.open('temp.zip') { |zip_file|
 zip_file.each { |f|
   f_path=File.join('public/javascripts', f.name)
   FileUtils.mkdir_p(File.dirname(f_path))
   zip_file.extract(f, f_path) unless File.exist?(f_path)
 }
}

run "rm temp.zip"

inside('public/javascripts/jquery-ui-1.7') do
  run "cp -r ui themes .."
end

run "rm -r public/javascripts/jquery-ui-1.7"

file "public/javascripts/application.js", <<-JS
$(function() {
  // ...
});
JS

git :add => "."
git :commit => "-a -m 'Added jQuery 1.3.2 with UI 1.7'"
