# app files
file 'app/controllers/application_controller.rb', 
%q{class ApplicationController < ActionController::Base

  helper :all

  protect_from_forgery

  filter_parameter_logging "password" unless Rails.env.development?

end
}

file 'app/helpers/application_helper.rb', 
%q{module ApplicationHelper
  def page_title(title=nil)
    if title.nil?
      @page_title ||= ""
    else
      @page_title = title
    end
  end

  def body_class
    "#{controller.controller_name} #{controller.controller_name}_#{controller.action_name}"
  end
end
}


Dir['config/locales/*.*'].map {|f| File.basename(f).split(".").first}.uniq.each do |locale|
  file "config/locales/#{locale}.app.yml", <<-YAML
#{locale}:
  app_name: "APP_NAME"
  YAML
end


if File.exists?('vendor/plugins/haml')

  file 'app/views/layouts/_flashes.html.haml', <<-HAML
#flash
  - flash.each do |key, value|
    %div{:id => "flash_\#{key}"}= value
HAML

  file 'app/views/layouts/application.html.haml', <<-HAML
!!!
%html{html_attrs}
  %head
    %meta{'http-equiv' => 'Content-Type', :content => 'text/html; charset=utf-8'}
    %link{ :rel => "shortcut icon", :href => "/favicon.ico", :type => "image/x-icon"}
    %title= "\#{page_title + ' - ' unless page_title.blank?}\#{t(:app_name)}"
    = stylesheet_link_tag 'screen.css', :media => 'screen, projection'
    = stylesheet_link_tag 'print.css', :media => 'print'
    /[if IE]
      = stylesheet_link_tag 'ie.css', :media => 'screen, projection'
  %body{:class => body_class}
    #header
      = render :partial => 'layouts/flashes'
    .container= yield
HAML
else

  file 'app/views/layouts/_flashes.html.erb', <<-ERB
<div id="flash">
  <% flash.each do |key, value| -%>
    <div id="flash_<%= key %>"><%=h value %></div>
  <% end -%>
</div>
ERB

  file 'app/views/layouts/application.html.erb', <<-ERB
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en-US" lang="en-US">
  <head>
    <meta http-equiv="Content-type" content="text/html; charset=utf-8" />
    <title><%= page_title + ' - ' unless page_title.blank? %><%=t :app_name %></title>
    <%= stylesheet_link_tag 'screen.css', :media => 'screen, projection' %>
    <%= stylesheet_link_tag 'print.css', :media => 'print' %>
    <!--[if IE]>
    <%= stylesheet_link_tag 'ie.css', :media => 'screen, projection' %>
    <![endif]-->
  </head>
  <body class="<%= body_class %>">
    <div id="header">
      <%= render :partial => 'layouts/flashes' -%>
    </div>
    <div class="container">  
      <%= yield %>
    </div>
  </body>
</html>
ERB

end


# initializers

initializer 'requires.rb', 
%q{Dir[Rails.root.join('lib', '*.rb')].each do |f|
  require f
end
}

gem 'quietbacktrace', :env => %w[development test]
gem 'capistrano'
rake "gems:install", :sudo=>true
capify!

git :add => "."
git :commit => "-a -m 'Added basic ApplicationController, helpers, layout, flashes, app localizations, initializers, capistrano'"
