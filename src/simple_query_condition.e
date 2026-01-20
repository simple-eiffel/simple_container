note
	description: "Abstract composable boolean condition for filtering"

deferred class
	SIMPLE_QUERY_CONDITION [G]

feature -- Evaluation

	satisfied_by (a_item: G): BOOLEAN
			-- Does `a_item` satisfy this condition?
		deferred
		end

feature -- Composition

	conjuncted alias "and" (a_other: SIMPLE_QUERY_CONDITION [G]): SIMPLE_AND_CONDITION [G]
			-- Condition satisfied when both self AND `a_other` satisfied
		deferred
		end

	disjuncted alias "or" (a_other: SIMPLE_QUERY_CONDITION [G]): SIMPLE_OR_CONDITION [G]
			-- Condition satisfied when self OR `a_other` satisfied
		deferred
		end

	negated alias "not": SIMPLE_NOT_CONDITION [G]
			-- Condition satisfied when self NOT satisfied
		deferred
		end

end
