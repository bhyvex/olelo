description  'Emacs org-mode filter'
dependencies 'engine/filter'
require      'org-ruby'

Filter.create :orgmode do |content|
  Orgmode::Parser.new(content).to_html
end
