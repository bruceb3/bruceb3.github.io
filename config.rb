require "redcarpet"

Time.zone = "Australia/Sydney"

activate :syntax

activate :blog do |blog|
  blog.permalink = "/:title"
  blog.sources = "/posts/:year-:month-:day-:title.html"
  blog.paginate = true
end

activate :directory_indexes

after_configuration do
  sprockets.append_path Modernizr.path
end

activate :relative_assets
set :relative_links, true

activate :directory_indexes
set :trailing_slash, false

page "/feed.xml", layout: false
page "/sitemap.xml", layout: false
page "/index.html", layout: :application
page "/posts/*", layout: :post

set :haml, format: :html5
set :markdown_engine, :redcarpet
set :markdown, fenced_code_blocks: true, smartypants: true, footnotes: true, autolink: true

set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'

configure :build do
  activate :minify_css
  activate :minify_js
end
