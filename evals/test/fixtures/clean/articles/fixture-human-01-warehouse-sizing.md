# Warehouse sizing is a scheduling problem

We spent three weeks arguing about whether the nightly load belonged on a medium or a large. The argument was
already lost before it started, because nobody had looked at when the queries actually ran.

The load window is forty minutes. Inside that window we run eleven jobs, and nine of them wait on the same two
tables. Adding compute does not shorten a queue that is serialized by a dependency. It buys you idle credits and a
nicer-looking graph.

We rewrote the DAG so the two blocking tables build first and the nine dependents fan out behind them. Same
warehouse, same code, same data. The window dropped to sixteen minutes.

The size question came back three weeks later, and by then it was answerable. With nine jobs running at once, a
medium spilled to remote storage on two of them and a large did not. We measured the spill instead of arguing about
the feel of it, then moved those two jobs up a size and left the other seven where they were.

What I want out of a sizing decision is a number I can defend six months from now in a budget review. "It felt
slow" is not that number. Bytes spilled to remote storage is.

The habit worth keeping is boring. Before you touch the size, draw the dependency graph and find out how much of
the window is spent waiting rather than computing. Most of the time the answer is embarrassing, and most of the
time it is free to fix.
