-define(VALIDATORS_LIST,
  [
    #string_validator{},
    #email_validator{}
  ]).

-record(string_validator,{
  type      = binary,
  property  = length,
  estate    = [min,max,allowEmpty]
}).

-record(email_validator,{
  type      = binary,
  property  = email,
  estate    = [email]
}).