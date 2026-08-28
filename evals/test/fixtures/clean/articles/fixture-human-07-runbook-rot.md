# Runbooks rot faster than code

The runbook for our ingestion service was eleven pages long and had been correct in 2023. By the time I read it at
two in the morning, four of the eleven pages referenced a service that no longer existed and one of them told me to
restart a host that had been decommissioned in a migration.

Code rots too, but code rots loudly. A dead function throws. A dead runbook step just wastes twenty minutes of the
worst twenty minutes anyone will have that month.

The version that survived was a page and a half. Three commands, each of which either fixes the problem or prints
the reason it cannot. One escalation path with a name and a phone number. One paragraph explaining what the service
is for, so the next person can reason about a failure the page does not cover.

We test it the only way a runbook can be tested. Every time it gets used, the person who used it edits it before
they go back to sleep, while the wrongness is still fresh. If nothing needed editing, they add a date at the
bottom.

Six months in, the file has nine dates and four edits. The edits are the interesting part. Two were commands that
had changed flags. One was a permission that had moved. One was an escalation contact who had changed teams and
would have been paged for a system she no longer owned.

None of those four would have been caught by a review, because a review reads the runbook the way the author wrote
it rather than the way an exhausted stranger reads it at two in the morning. The only honest test of a runbook is
somebody following it under the conditions it was written for.

The page and a half is worse documentation than the eleven pages. It is a much better runbook.
