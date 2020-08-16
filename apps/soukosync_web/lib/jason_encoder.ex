require Protocol

# This file is to fix this error:
# * (Protocol.UndefinedError) protocol Jason.Encoder not implemented for %HTTPoison.Error{id: nil, reason: :timeout} of type HTTPoison.Error (a struct), Jason.Encoder protocol must always be explicitly implemented.
#
# [...]
#
# Finally, if you don't own the struct you want to encode to JSON, you may use Protocol.derive/3 placed outside of any module:
#
#    Protocol.derive(Jason.Encoder, NameOfTheStruct, only: [...])
#    Protocol.derive(Jason.Encoder, NameOfTheStruct)
#. This protocol is implemented for the following type(s): Ecto.Schema.Metadata, Ecto.Association.NotLoaded, Jason.Fragment, Decimal, DateTime, NaiveDateTime, Time, Date, BitString, Map, List, Float, Integer, Atom, Any

Protocol.derive(Jason.Encoder, HTTPoison.Error)
