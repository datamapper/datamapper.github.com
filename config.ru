require 'nanoc3'

autocompiler = Nanoc3::Extra::AutoCompiler.new('.')
app = Rack::Builder.new do
  use Rack::CommonLogger, $stderr
  use Rack::ShowExceptions
  run autocompiler
end.to_app

run(app)
