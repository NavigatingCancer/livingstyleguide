require 'erb'
require 'hooks'
require 'rouge'

class LivingStyleGuide::CodeBlock
  include Hooks
  include Hooks::InstanceHooks
  include LivingStyleGuide::FilterHooks
  include Rouge
  define_hooks :filter_code, :syntax_highlight

  attr_accessor :source, :language

  syntax_highlight do |code|
    if language.nil?
      code
    else
      highlight(code, language)
    end
  end

  def initialize(source, language = nil)
    @source = source
    @language = language
  end


  def initialize(source, language = nil)
    @source = source
    @language = nil
    @_language = language
  end

  def render
    code = @source.strip
    formatter = Rouge::Formatters::HTML.new(css_class: 'highlight', line_numbers: true)
    lexer_class = "Rouge::Lexers::#{@_language.to_s.split('-').join.camelize}".constantize
    lexer = lexer_class.new
    output = formatter.format(lexer.lex(code))
    %Q(<style type="text/css">#{Rouge::Themes::Github.render(scope: '.highlight')}</style>
      <div class="code-block">
        <div class="lang">#{@_language}</div>
        #{output}
      </div>)
  end

end

