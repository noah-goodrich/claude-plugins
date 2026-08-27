# Schema drift is a contract failure, not a data failure

A column changed type from integer to string in an upstream service on a Tuesday. Six models downstream started
returning nulls on Wednesday. The finance dashboard was wrong for nine days before anyone noticed, and it was the
controller who noticed, not us.

The postmortem wanted to talk about alerting. I wanted to talk about who owed whom what.

Nobody upstream had agreed to anything. There was no contract, so there was no breach, so there was nothing to
alert on. We had built a very good smoke detector in a building with no fire code.

What worked was small and social. We wrote down the twelve columns we actually depended on, took that list to the
two service teams who owned them, and asked for one thing: tell us before you change these. Not a schema registry,
not a governance program. A list of twelve columns and two names.

Both teams said yes in under a week, because we had asked for twelve columns rather than for their whole schema.

The registry came later and it was easier to sell, because by then two teams could say out loud that the process
had already saved them a rollback.
