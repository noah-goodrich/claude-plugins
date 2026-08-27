# The on-call rotation was the design review

For two years our data platform had no design review. It had an on-call rotation, and the rotation did the review
after the fact, at three in the morning, with the worst possible information.

You can read a team's architecture off its pager. Ours said: forty-one alerts a week, thirty of them on the same
six tables, and every one of those six was a table somebody had built alone in a sprint that ended on a Friday.

That said, the pager was honest in a way the design docs were not. The docs described a system where every model
had an owner and a freshness SLA. The pager described a system where four models had owners, the rest had a Slack
channel, and freshness meant whatever the last person to touch it assumed.

We did the cheapest thing available. Every alert that fired twice in a month got a fifteen-minute review with two
people and a written outcome: fix it, delete it, or accept it and turn the alert off. Ninety minutes a week, total.

After a quarter the pager was down to nine alerts a week. We deleted eleven models nobody had opened in a year. We
accepted four alerts as noise and silenced them on purpose, which is different from silencing them by ignoring
them.

Nothing about that was clever. The only insight was that we already had the review, we were just holding it at
three in the morning with one exhausted person instead of at two in the afternoon with two rested ones.
