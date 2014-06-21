
require 'sqlite3'
# require 'nokogiri'
require 'Bento'

module Confetti

#----------------------------------------------------------------------------------------------

class Activity
	include Bento::Class

	attr_reader :name, :user

	#------------------------------------------------------------------------------------------

	def initialize(*opt)
		return if init_with_tag(:create, opt)

		init([:name], [], [], opt)
		fail if !@name
		row = db.get_first_row("select name, view, branch, root, user, project from activities where name='#{@name}'")
		fail if row == nil
		_from_row(row)
	end

	def Activity.create(*opt)
		Activity.new(opt, :create)
	end

	#------------------------------------------------------------------------------------------

	def exists?
		db.get_first_value("select count(*) from activities where name='#{name}'") == 1
	end	
	
	#------------------------------------------------------------------------------------------

	def branch
		ClearCASE::Branch.new(@branch)
	end 
	
	def view
		ClearCASE::View.new(@view)
	end	

	#------------------------------------------------------------------------------------------

	def checkouts
		view.checkouts
	end
	
	def active_elements
		view.on_branch(branch)
	end

	#------------------------------------------------------------------------------------------

	def last_mark
		db.get_first_value("select last_mark from activities where name='#{@name}'")
	end

	def inc_mark
		db.execute("update activities set last_mark = last_mark + 1 where name='#{@name}'")
		last_mark
	end

	def last_mark_name
		Activity.mark_name(@name, last_mark)
	end

	def new_mark_name
		Activity.mark_name(@name, inc_mark)
	end

	def Activity.mark_name(name, mark)
		"#{name}_mark_#{mark}"
	end

	# flags: keepco

	def mark!(lot = nil, *flags)
		lot = lot == nil ? nil : lot.is_a?(ClearCASE::Lot) ? lot : Lot.new(lot)
		keepco = flags.include?(:keepco)

		checkouts = view.checkouts
		checkouts = lot.filter_elements(checkouts) if lot
		checkin_done = false
		begin
			checkouts.checkin
			checkin_done = true
			
			bra_elements = view.on_branch(branch)
			bra_elements = lot.filter_elements(bra_elements) if lot
			return if bra_elements.empty?
	
#			dir_closure = bra_elements.directory_closure
			
			mark_name = new_mark_name
			bra_elements.label!(mark_name, :recursive)

#			label_args = {name: mark_name}
			label_args[:root_vob] = @root if @root
			ClearCASE::LabelType.create(label_args)

#			dir_closure.label!(mark_name, :nocreate)
#			bra_elements.label!(mark_name, :recursive, :nocreate)
		rescue => x
			puts x
		ensure
			checkouts.checkout if checkin_done && keepco
		end
	end	

	#------------------------------------------------------------------------------------------
	private
	#------------------------------------------------------------------------------------------
	
	def db
		Confetti::DB.global
	end

	def _from_row(row)
		@view = row['view']
		@branch = row['branch']
		@user = row['user']
		@project = row['project']
		@root = row['root']
		
		@view = "#{@view}/#{@root}" if @root != ""
	end

	#------------------------------------------------------------------------------------------

	def create(opt)
		init([:name], [:user, :branch, :view, :project, :root], [:raw, :jazz], opt)
		fail if !@name

		@user = System.user if !@user && !@raw
		@name = "#{@user}_#{@name}" if !@raw
		@name += "_" + Bento.rand_name if @jazz
		@branch = "#{@name}_br"  if !@branch
		@view = "#{@name}" if !@view
		@project = "main" if !@project
		@root = '' if !@root
		@last_mark = 0

		raise "create activity #{@name} failed: already exists" if exists?

		br_args = {name: @branch}
		br_args[:root_vob] = @root if @root
		ClearCASE::Branch.create(br_args)

		view_args = {name: @view}
		view_args[:root_vob] = @root if @root
		ClearCASE::View.create(view_args)

		db.execute("insert into activities (name, view, branch, root, user, project, last_mark) " +
			"values ('#{@name}', '#{@view}', '#{@branch}', '#{@root}', '#{@user}', '#{@project}', #{@last_mark})")
	end
	
end # Activity

#----------------------------------------------------------------------------------------------

class Activities

	def initialize(names)
		@names = names
	end

	def each
		@names.each { |name| yield Activity.new(name) }
	end

end # Activities

#----------------------------------------------------------------------------------------------

class CurrentActivity < Activity

	def initialize
		view = ClearCASE::CurrentView.new
		super(name: view.name)
	end

end # CurrentActivity

#----------------------------------------------------------------------------------------------

end # module Confetti
