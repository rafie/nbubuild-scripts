checkouts = view.checkouts
checkouts = lot.filter_elements(checkouts)
checkouts.checkin

bra_elements = view.on_branch(bra)
bra_elements = lot.filter_elements(bra_elements)
bra_elements_closure = bra_elements.directory_closure		

return if bra_elements_closure.empty?

mark = act.new_mark_name
bra_elements.label!(new_mark_name)

return if ! keepco

checkouts.checkout
