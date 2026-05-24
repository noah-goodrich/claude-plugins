---
title: "Snowflake vs Databricks"
url: https://medium.com/@noah.goodrich/snowflake-vs-databricks-ecd539ed7f77
date: 2023-09-25
publication: personal
reading_time_min: 5
claps_response_count: 2
tags: [snowflake, databricks, cloud-computing, data-engineering]
subtitle: "Why the argument presents a false dichotomy"
---

# Snowflake vs Databricks

## Why the argument presents a false dichotomy

I think I'm tired of the Snowflakes vs Databricks war. The way some people talk about one or the other you'd think that the two companies are locked in mortal combat and only one can emerge from the pit alive. Personally, I think the only answer to "which is better?" is "it depends".

Let me explain.

### Macs vs PCs, Ferrari vs American Muscle

Years ago I was talking to a coworker about Macs vs PCs (Linux, not Windows) and made this observation: "Macs are like Ferrari and PCs are like American muscle cars". My reasoning was that people who buy Macs obviously love their machine to be beautiful and flawless and they don't want to futz with hardware or software to "get stuff done". On the other hand, being an avid (amateur) Linux user at the time I spent a lot of time ogling the beautiful custom-built machines with water cooling and flashy lights and the equally beautiful custom-built OS interfaces designed by master Linux users. For Linux folks, there is a large satisfaction in designing and building something that is their own creation. I've known people who would immediately begin building a new machine as soon as they finished building their current one. Linux users are also ok with occasionally reinstalling drivers or other software to "make things work". For them it's all part of the experience.

One could argue that neither Macs nor Linux PCs are better. Rather they represent two very divergent cultures. From what I've observed, Ferrari owners are probably (since I don't personally know any) a lot like Mac owners — they want a beautiful, high performance machine that they can just enjoy driving. On the other hand I've actually known a few people who had American muscle cars. One thing they've all shared in common was the pride they expressed in building the car themselves and all of the customizations that made their car unique. For those folks, there was as much, if not more, joy in the act of building the car as there was in driving it.

### Databricks is for tinkerers, Snowflake isn't

I interviewed a guy last year whose team had successfully rolled out Databricks and Delta Lake. Given my own failed attempt to do so just months prior, I asked him how much time they spent on maintenance to keep Delta Lake working smoothly. His answer was roughly 20%. In a team of 5 data engineers, that means that one whole person would be required to maintain their data lake. I've also talked to other people who love Databricks. It seems like a common theme for these teams is that they were migrating from on-prem servers (or the equivalent in AWS EC2 instances) and had existing teams with deep experience with Spark and managing the infrastructure for it.

Having been part of the team at my last company that ultimately decided to go with Snowflake and then having migrated from trying to use Delta Lake to an existing Snowflake instance, I can tell you that I can run Snowflake with only a basic understanding of the storage and compute model it uses and with zero support from IT or devops folks. Given the size of my team and our general lack of expertise with Spark, using Snowflake was at first a matter of survival. Using Snowflake was the only way to get our head above water. Now, we choose to use it so we can focus on business problems rather than spending time on infrastructure or platform issues.

So back to the question of which is better.

### Comparing Ferrari to American muscle is a little non-sensical

I love watching Top Gear (the good one with The Orangutan, Captain Slow, and the Hamster). For anyone not familiar with the show, a core component involves the hosts driving through beautiful scenery (seriously, the videography is one of my favorite things about the show) in expensive cars and reviewing them. Something I've noticed is that while they frequently compare Jaguars, Ferraris, Lamborghinis, and other European sports cars, they seldom compare them to American muscle cars. And its not because they never review American muscle cars because they do. I think they don't because there is an inherent understanding that in general the same people aren't shopping for either a Mustang or a Ferrari. The question of which is better comes down in part to whether you're racing quarter-mile stretches between stop lights and hanging out at classic car shows or driving a twisty well-paved highway in Europe.

### There is plenty of room at the table for both

Here I'm going to make the same argument about Snowflake and Databricks. In this case, Snowflake is the Ferrari and Databricks the Mustang. Both will get you to your destination, but the experience will be vastly different.

Earlier today I was reading a post from someone talking about Capital One's investment in Databricks and the obvious correlation that they must be losing confidence in Snowflake. Because obviously this is a zero-sum game and only one of the two can emerge victorious (*sarcasm*).

I'd like to introduce you to this guy:

Jay Leno owns somewhere in the neighborhood of 181 cars. You can go google a list of his cars, but suffice it to say that he has a mix of both European sports cars and American muscle cars along with a host of others. For someone who just loves cars and has gobs of money, the obvious answer is to own some of both.

I think for a company the size of Capital One, it only makes sense that they would have some projects where Snowflake makes more sense and others where Databricks makes more sense.

Anyone evaluating Databricks and Snowflake would do well to ask themselves which product's culture best fits their team rather than asking which is "better" because the answer to "which is better" is always going to be "it depends".
