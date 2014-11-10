-define(VALIDATORS_LIST,
  [
    #length_validator{},
    #email_validator{}
  ]).

-record(length_validator,{
  type      = binary,
  property  = length,
  estate    = [min,max,is]
}).

-record(email_validator,{
  type      = binary,
  property  = email,
  estate    = [email]
}).