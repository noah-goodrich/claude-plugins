# Late data is not an exception

Every pipeline I have inherited treated late-arriving rows as a bug report. Something showed up after the partition
closed, someone filed a ticket, and a human ran a backfill by hand at nine at night.

Late data is not a bug. It is the normal behavior of a distributed system with a mobile client in it. A phone in
airplane mode over the Atlantic will hand you yesterday's events tomorrow, and no amount of upstream scolding will
change that.

The fix is to stop designing around the arrival time and start designing around the event time. Partition on when
the thing happened. Keep a small, cheap reprocessing window that reopens the last seven days on every run. Accept
that the last seven days of any dashboard are provisional and say so on the dashboard itself.

We did this in March. Backfill tickets went from about nine a month to one, and the one was a real upstream outage
rather than a phone on a plane.

The cost was a slightly larger nightly job and a footnote on four dashboards. I would take that trade every time.
