# ActivityMetadata_spec.rb
require '../ActivitiesMetadata'



describe ActivitiesMetadata do		
		
		activityMetadataFileName = "testMetadata.xml" #TODO amib find a better place for the file than just storing locally.
		activityName = "testActivity"
		activityName2 = "testActivity2"
		
		before(:each) do
				if File::exists?(activityMetadataFileName)
					File.delete(activityMetadataFileName)
				end
		end
		
	describe ActivitiesMetadata do
		
		it "Metadata file should exist on instantiation" do
		activitiesMetadata = ActivitiesMetadata.new(activityMetadataFileName)	
		File::exists?(activityMetadataFileName).should be true
		end
		
		it "Metadata file should be gone once deleted" do
		activitiesMetadata = ActivitiesMetadata.new(activityMetadataFileName)	
		activitiesMetadata.deleteMetadata(activityMetadataFileName)
		File::exists?(activityMetadataFileName).should be false
		end
				
		it "Activity should not exist prior to creation" do
		activitiesMetadata = ActivitiesMetadata.new(activityMetadataFileName)	
		activitiesMetadata.activityAlreadyExists?(activityName).should be false		
		end					
		
		it "Activity should exist after its creation" do		
		activitiesMetadata = ActivitiesMetadata.new(activityMetadataFileName)
		activitiesMetadata.startNewActivity(activityName)
		activitiesMetadata.activityAlreadyExists?(activityName).should be true					
		end		
		
		it "Activity should have index 1 on creation" do		
		activitiesMetadata = ActivitiesMetadata.new(activityMetadataFileName)
		activitiesMetadata.startNewActivity(activityName)
		activitiesMetadata.getLabelIndex(activityName).should == "1"		
		end
		
		it "Activity should have index 2 once raised" do		
		activitiesMetadata = ActivitiesMetadata.new(activityMetadataFileName)
		activitiesMetadata.startNewActivity(activityName)
		activitiesMetadata.raiseLabelIndex(activityName)
		activitiesMetadata.getLabelIndex(activityName).should == "2"		
		end
		
		it "Activity should not exist once deleted" do		
		activitiesMetadata = ActivitiesMetadata.new(activityMetadataFileName)
		activitiesMetadata.startNewActivity(activityName)
		activitiesMetadata.raiseLabelIndex(activityName)		
		activitiesMetadata.deleteActivity(activityName)
		activitiesMetadata.activityAlreadyExists?(activityName).should be false					
		end
		
		it "Activity should be able to handle multiple activities" do		
		activitiesMetadata = ActivitiesMetadata.new(activityMetadataFileName)
		activitiesMetadata.startNewActivity(activityName)
		activitiesMetadata.startNewActivity(activityName2)
		activitiesMetadata.raiseLabelIndex(activityName)		
		activitiesMetadata.raiseLabelIndex(activityName2)
		activitiesMetadata.deleteActivity(activityName)
		activitiesMetadata.raiseLabelIndex(activityName2)
		activitiesMetadata.getLabelIndex(activityName2).should == "3"		
		end
		
		it "It should not be possible to create two identical activities" do		
		activitiesMetadata = ActivitiesMetadata.new(activityMetadataFileName)
		activitiesMetadata.startNewActivity(activityName).should be true		
		activitiesMetadata.startNewActivity(activityName).should be false		
		end
		
		it "Metadata should maintain previously raised indices" do		
		activitiesMetadata = ActivitiesMetadata.new(activityMetadataFileName)
		activitiesMetadata.startNewActivity(activityName).should be true		
		activitiesMetadata.raiseLabelIndex(activityName)
		
		activitiesMetadata2 = ActivitiesMetadata.new(activityMetadataFileName)
		activitiesMetadata2.getLabelIndex(activityName).should == "2"
		
		end
		
		
		
		
		
			
	end	
   
end