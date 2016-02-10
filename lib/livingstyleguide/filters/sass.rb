LivingStyleGuide::Example.add_filter :sass do
  begin

    require 'sass'
    @syntax = :sass

    sass_options = { load_paths: Rails.application.assets.paths }
    pre_processor do |sass|
      Sass::Engine.new(sass, sass_options).to_tree.render
    end

  rescue LoadError
    raise "Please make sure `gem 'sass'` is added to your Gemfile."
  end
end

