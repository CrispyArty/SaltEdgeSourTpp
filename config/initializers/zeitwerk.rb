Dir.glob(Rails.root.join("app/services/**/concerns")).each do |dir|
  Rails.autoloaders.main.collapse(dir)
end
