mutable struct VLGRNSentence

    original_sentence::String
    sentence_actor_clause::String
    sentence_action_clause::String
    sentence_target_clause::String
    sentence_delimiter::Char
  
    function VLGRNSentence()
      this = new()
    end
end

mutable struct VLMetabolicReaction

    record::String
    reaction_name::String
    ec_number::String
    left_phrase::String
    right_phrase::String
    reversible::String

    function VLMetabolicReaction()
		  this = new()
	end
end

mutable struct VLMetabolicSpeciesReference

  species_symbol::String
  stoichiometry::String

  function VLMetabolicSpeciesReference()
    this = new()
  end
end

mutable struct VLSequenceRecord
  
  record::String
  operationType::Symbol
  sequence::String
  enzymeSymbol::String
  modelSpecies::String
  length::Int

  function VLSequenceRecord()
    this = new()
  end
end

mutable struct VLSpeciesSymbol

  species_type::Symbol
  species_symbol::String

  function VLSpeciesSymbol()
		this = new()
	end
end

mutable struct VLProgramComponent

  filename::String
  buffer::String
  vector::Array{Float64,1}
  matrix::Array{Float64,2}
  type::Symbol

  function VLProgramComponent()
    this = new()
  end

end

mutable struct VLGRNConnectionObject

  connection_symbol::String
  connection_actor_set::Array{VLSpeciesSymbol,1}
  connection_target_set::Array{VLSpeciesSymbol,1}
  connection_type::Symbol

  function VLGRNConnectionObject()
    this = new()
  end
end