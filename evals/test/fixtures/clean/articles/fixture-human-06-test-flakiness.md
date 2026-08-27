# A flaky test is a design smell with a retry button

We had a suite with nine tests that failed maybe one run in six. The team's response was a retry decorator, which
is the engineering equivalent of putting tape over a check-engine light.

I pulled the nine. Seven of them shared a root cause: they asserted on wall-clock ordering in a system that makes
no ordering promise. The test was not flaky. The test was wrong, and it happened to be right most of the time.

It's worth noting that the other two earned their keep. They caught a race in the connection pool that had been
eating one request in forty thousand in production, which nobody had ever traced because one in forty thousand
looks like a client problem from the server side.

We deleted seven tests and fixed one bug. The suite went green and stayed green for four months.

The retry decorator came out in the same change. Two people argued to keep it as a safety net. My objection was
that a safety net you cannot see through is a blindfold, and we had already spent four months wearing one.

Retries hide the difference between a test that is wrong and a system that is wrong, and that difference is the
only thing the test was ever for.
