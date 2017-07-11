# configure :production, :development do
# 	db = URI.parse(ENV['DATABASE_URL'] || 'postgres://localhost/development')
#
# 	ActiveRecord::Base.establish_connection(
# 			:adapter => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
# 			:host     => db.host,
# 			:username => db.user,
# 			:password => db.password,
# 			:database => db.path[1..-1],
# 			:encoding => 'utf8'
# 	)
# end

configure :production, :development do
data = YAML.load_file('config/database.yml')['development']
db = OpenStruct.new(data)

    ActiveRecord::Base.establish_connection(
            :adapter => db.adapter,
            :host     => db.host,
            :username => db.username,
            :password => db.password,
            :database => db.database,
            :encoding => 'utf8'
    )
end
