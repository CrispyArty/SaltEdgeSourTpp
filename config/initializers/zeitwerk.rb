Rails.root.glob("app/services/**/concerns").each do |dir|
  Rails.autoloaders.main.collapse(dir)
end
