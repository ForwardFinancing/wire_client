# Require all of the files in lib
Dir[Gem::Specification.find_by_name("wire_client").gem_dir + '/lib/**/*.rb'].sort.each do |f|
  require(f.split('/lib/').last.split('.rb').first)
end

# Adapter for interacting with Wire transfer service providers
module WireClient
end
