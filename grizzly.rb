# -*- encoding : utf-8 -*-
	
raise "pivotal-tracker required. \ngem install pivotal-tracker" if Gem::Specification::find_all_by_name('pivotal-tracker').empty?

require "pivotal-tracker"
require 'rubygems'
require 'active_resource'
require 'curb'
require 'json'
require 'mime/types'
require 'csv'

require './config.rb'
#Redmine active resources
require './redmine.rb'



class Hash
  def collect!(&block)
    ret = []
    self.each {|key,val|
      if val.kind_of? Array
        val.collect!{|subval|
          block.call subval
        }
        ret = val
      end
    }
    return ret
  end
end


PivotalTracker::Client.token(PT[:USER], PT[:PASS])

@pt_webapp = PivotalTracker::Project.find(PT[:PROJECT_ID])

redmine_issues = Redmine::Issue.all(:params  => {:status_id => "*"})

@ids = Hash.new

CSV.foreach("ids.csv") {  |row| @ids[row[0].to_i] = row[1].to_i }




#Redmine
#tracker 1 -bug, 2 - Feature, 3 - support, 4 - update
#status 1 -new, 2 - in progress, 3 - resolved, 4- feeedback, 5- closed, 6 - rejected



c = 0
#web app stories
@stories = @pt_webapp.stories.all

@stories.each do |story|

	story = @pt_webapp.stories.find(story.id)


		#feature, bug, chore, release
		status = 1
		tracker = 2

		case story.story_type 
		when "feature"
			tracker = 2
		when "bug"
			tracker = 1
		when "chore"
			tracker = 3
		when "release"
			tracker = 4
		end

		case story.current_state
		when "accepted"
			status = 5
		when "rejected"
			status = 6
		when "started"
			status = 2
		when "unscheduled"
			status = 1
		when "unstarted"
			status = 1
		when "delivered"
			status = 3
		end
			

		#first check issue already exist check 
		
		#raise redmine_issues.first.inspect

		#issue = redmine_issues.detect {|issue| !issue.custom_field_values["pt_id"].nil? and issue.custom_field_values["pt_id"] == story.id }

		#raise issue.inspect


		

		if @ids[story.id].nil?
		#create new	
		
			#upload attachments
			login_shell = %x( ./login #{PT[:USER]} #{PT[:PASS]})

			uploads = Array.new 

			story.attachments.each do |attachment| 

				file_tmp_path = "tmp/#{attachment.filename}"

				save_atachemnt = %x(./get-attachment.sh #{attachment.id} #{file_tmp_path})	


				curl = Curl::Easy.new("#{REDMINE[:URL]}uploads.json") do |http|
					 http.headers['Content-Type'] = 'application/octet-stream'
					 http.ssl_verify_peer = false
				end
				curl.http_auth_types = :basic
				curl.username = REDMINE[:USER]
				curl.password = REDMINE[:PASS]
				#curl.multipart_form_post = true
				
				file_content = File.open(file_tmp_path, 'rb') { |file| file.read }	

				#res = clnt.post("#{REDMINE[:URL]}uploads.xml", StringIO.new(contents))

				curl.http_post(file_content)
				
				puts curl.body_str  

				response = JSON.parse(curl.body_str)	
				token = response["upload"]["token"]

				upload = {"token" => token, 
									"filename" => attachment.filename, 
									"description" => attachment.description, 
									"content_type" =>  MIME::Types.type_for(file_tmp_path).first
								}

				uploads << upload					
									
				
			end

			puts uploads
			

			issue = Redmine::Issue.new(
			  :subject => story.name,
			  :description => story.description,
			  :tracker_id => tracker,
			  :status_id => status,
			  :assigned_to_id => REDMINE[:USER_ID],
			  :project_id => REDMINE[:PROJECT_ID],
			  :start_date => story.created_at.strftime("%Y-%m-%d"),
			  :custom_field_value => {'pt_id' => story.id},
			  :uploads => uploads
			)

			issue.save!		
			
			CSV.open("ids.csv", "ab") do |csv|
			  csv << [story.id, issue.id]
			end



		#update exisiting issue	
		else
			
			issue = Redmine::Issue.find(@ids[story.id])	
			issue.subject = story.name
			issue.description = story.description
			issue.tracker_id = tracker
			issue.status_id = status
			issue.save

		end	

		c = c +1
		#raise "x" if c > 2

		story.accepted_at
		story.estimate
		story.current_state
		story.requested_by
		story.owned_by

	

end