
require 'sqlite3'

require 'Bento'

module Confetti

$confetti_test = false

GLOBAL_DB_PATH = "R:/Build/sys/scripts/ruby/Confetti/db/global.db"
GLOBAL_TEST_DB_PATH = "R:/Build/sys/scripts/ruby/Confetti/db/test/global.db"

DB_VIEWPATH = "/nbu.meta/db/local.db"

#----------------------------------------------------------------------------------------------

class User
	attr_reader :name

	def initialize(name)
		@name = name
	end

end # User

#----------------------------------------------------------------------------------------------

class DB

	@@global_db = nil

	def DB.global_db
		class_variable_get(:@@global_db)
	end

	def DB.global
		if DB.global_db == nil
			class_variable_set(:@@global_db, SQLite3::Database.new(DB.global_path))
			DB.global_db.results_as_hash = true
		end
		DB.global_db
	end
	
	def DB.global_path
		$confetti_test_mode ? GLOBAL_TEST_DB_PATH : GLOBAL_DB_PATH
	end

end # DB

#----------------------------------------------------------------------------------------------

end # module Confetti
