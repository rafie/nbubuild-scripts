
module Bento

#----------------------------------------------------------------------------------------------

module Class

	# opt is of the form ([] stands for optinoal): ord-args args-hash flags
	# ord-args are scanned until a hash is encountered
	# note that in order to pass a hash as an ord-arg it should be wrapped in an array

	def init(ord_args, named_args, flag_args, opt)
		ord_args.each do |a|
			break if opt[0].is_a?(Hash)
			instance_variable_set("@#{a}", opt.shift)
		end
		
		args = opt.shift
		args = [] if args == nil
		
		named_args.concat(ord_args)
		named_args.each do |a|
			instance_variable_set("@#{a}", args[a]) if args.include? a
		end

		flags = opt
		flag_args.each do |f|
			instance_variable_set("@#{f}", true) if flags.include? f
		end
	end

	# opt is of the form [[{options}] tag]

	def init_with_tag(tag, opt)
		return false if opt.length != 2 || opt[1] != tag
		send(tag, opt[0]) 
		return true
	end

end # BentoClass

#----------------------------------------------------------------------------------------------

end # module Bento
