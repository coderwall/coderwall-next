namespace :tags do
  desc "Replace tags with canonical usages"
  task :clean do
    replacements = {
      'javascript' => [
        '#javascript',
        '.js',
        'javascripts',
      ],
      'nodejs' => [
        'javascript. node.js',
        'node js',
        'node-js',
        'node.js node',
        'node.js',
      ],
      'rails' => [
        'ruby rails',
        'ruby on rails',
        'ruby in rails',
        'ruby-on-rails',
        'rubyonrails',
      ],
    }

    replacements.each do |canonical, tags|
      Protip.with_any_tagged(tags).each do |tip|
        clean = tip.tags.map{|t| tags.find {|wrong| t == wrong } ? canonical : t }.uniq
        tip.update_columns(tags: clean)
      end
    end
  end
end
