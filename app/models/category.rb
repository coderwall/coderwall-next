class Category
  All = {
    'git'          => ['git', 'gitconfig', 'github'],
    'nodejs'       => ['node', 'npm', 'gulp', 'node.js'],
    'vim'          => ['vim', 'vi', 'viml'],
    'ruby'         => ['ruby', 'rvm', 'rake'],
    'rails'        => ['rails', 'activerecord', 'ruby on rails', 'heroku'],
    'command-line' => ['vim', 'bash', 'shell', 'ssh', 'cli', 'grep', 'zsh', 'terminal'],
    'front-end'    => ['javascript', 'react', 'react.js', 'js', 'angular.js', 'angular.js', 'jquery', 'backbonejs'],
    'web'          => ['html5', 'css', 'css3', 'fonts', 'html', 'web', 'browser', 'svg'],
    'dot-net'      => ['vb.net', 'asp.net', 'c#', 'csharp', '.net', 'linq'],
    'devops'       => ['devops', 'docker', 'ansible', 'vagrant', 'sysadmin'],
    'ios'          => ['ios', 'objective-c', 'swift', 'xcode', 'iphone'],
    'android'      => ['android', 'google now'],
    'os-hacks'     => ['linux', 'macosx', 'mac', 'os x', 'ubuntu', 'debian', 'windows']
  }

  class << self

    def top
      All.keys
    end

    def name(tag)

    end

    def parent(tag)
      @reverse_lookup ||= begin
        hash = {}
        All.each do |key, values|
          values.each{|value| hash[value] = key}
        end
        hash
      end
      parent = @reverse_lookup[tag]
      parent if parent != tag
    end

    def is_parent?(tag)
      All[tag] && tag
    end

    def children?(tag)
      !children(tag).empty?
    end

    def color
      (@colors ||= BasscssColorCombos.split("\n").collect(&:strip)).sample
    end

    def children(tag)
      All[tag] || []
    end
  end

  BasscssColorCombos = "white bg-navy
  black bg-lime
  lime bg-black
  black bg-yellow
  yellow bg-black
  black bg-silver
  lime bg-navy
  navy bg-lime
  yellow bg-navy
  navy bg-yellow
  silver bg-navy
  navy bg-silver
  navy bg-aqua
  aqua bg-navy
  black bg-teal
  white bg-maroon
  green bg-black
  teal bg-navy
  navy bg-teal
  black bg-orange
  green bg-navy
  navy bg-green
  gray bg-navy
  navy bg-gray
  lime bg-maroon
  yellow bg-maroon
  maroon bg-yellow
  silver bg-maroon
  orange bg-navy
  navy bg-orange
  maroon bg-aqua
  aqua bg-maroon
  white bg-purple
  black bg-fuchsia
  maroon bg-teal
  red bg-navy
  olive bg-navy
  navy bg-olive
  navy bg-fuchsia
  fuchsia bg-navy
  purple bg-lime
  purple bg-yellow
  yellow bg-purple
  silver bg-purple
  orange bg-maroon
  maroon bg-orange
  white bg-fuchsia
  purple bg-aqua
  navy bg-blue
  blue bg-navy
  blue bg-lime
  blue bg-yellow
  lime bg-blue
  yellow bg-blue
  black bg-purple"
end
