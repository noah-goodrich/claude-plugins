# The cost review nobody wanted to run

Our platform bill grew forty percent in a quarter and the first four explanations were all wrong. It was not the
new team. It was not the ML workload. It was not the vendor's pricing change, which had actually moved in our
favor.

It was one dashboard, refreshing every five minutes, that eleven people had bookmarked and two people looked at.

Finding it took an afternoon and a query against the usage views, grouped by warehouse and then by query hash. The
top line was thirty-one percent of the increase all by itself. The second line was a test suite somebody had wired
to a scheduler in 2024 and then left a company over.

We changed the refresh to hourly and asked the two viewers if that was acceptable. Both said they had never
noticed the five-minute cadence in the first place.

What bothers me about this story is not the waste. It is that the bill had been growing for two quarters and every
conversation about it had been a conversation about policy. Nobody had run the query.

I now put a standing thirty-minute block on the calendar the week after every close. One person, one query, top ten
consumers by delta. It has caught something every quarter since, and it has never once needed a policy.
