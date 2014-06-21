# activity_spec.rb
require '../Confetti'

describe Confetti::Activity, do
  it "has a name property" do
	name= "test1"
    activity = Confetti::Activity.new(name)
    
    activity.name.should eq(name)
  end
  
  it "does not initially exist" do
	activityName= "temp_act_name"
    activity = Confetti::Activity.new(activityName)
    
    activity.exists?.should be false
  end
  
  it "exists once created" do
	activityName= "temp_act_name"
    activity = Confetti::Activity.new(activityName)
	activity = Confetti::Activity.materializeActivity(activityName)
    
    activity.exists?.should be true	
  end
  
end