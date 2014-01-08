# Redmine Active Recources
module Redmine

	class Issue < ActiveResource::Base
	  self.site = REDMINE[:URL]
	  self.user = REDMINE[:USER]
	  self.password = REDMINE[:PASS]
	  self.format = :xml
	end

	class Project < ActiveResource::Base
	  self.site = REDMINE[:URL]
	  self.user = REDMINE[:USER]
	  self.password = REDMINE[:PASS]
	  self.format = :xml
	end

	class Upload < ActiveResource::Base
	  self.site = REDMINE[:URL]
	  self.user = REDMINE[:USER]
	  self.password = REDMINE[:PASS]
	  self.format = :xml
	end

end