---
name: linkedin-post
description: "LinkedIn post creation skill optimized for engagement and click-through. Use whenever the user asks for a LinkedIn post, says 'share on LinkedIn,' 'promote this article,' 'write a post for,' requests social media promotion, mentions LinkedIn content strategy, or wants to announce something professionally. Also trigger when reviewing or editing existing LinkedIn drafts. This skill creates posts specifically optimized for the LinkedIn algorithm, Noah's voice, and click-through behavior (not just views). Always produces 2 variant posts with different strategic hooks."
---

# LinkedIn Post Creation Skill

Creates LinkedIn posts optimized for engagement, specifically click-through rate (not just impressions). Every post must sound like Noah, pass AI detection, and work with the LinkedIn algorithm.

## Dependencies

- **noah-voice**: Read and apply voice rules before writing. The post must sound like Noah.
- **ai-scoring**: Run the scoring pass on each variant before presenting. LinkedIn posts should score 75+.

Read the `noah-voice` skill's `references/voice-rules.md` and at least skim one example article before writing. Then read `references/linkedin-examples.md` in this skill's directory for patterns from Noah's highest-performing posts.

## LinkedIn Algorithm Rules

### The Fold (Most Critical)
The "see more" fold on mobile is approximately **210 characters** (first 2-3 lines). Everything above that fold determines whether someone reads the rest. The hook must create enough tension, curiosity, or recognition that the reader taps "see more."

**Good hooks from Noah's top posts:**
- "I love using Cursor. It has completely changed how I write code. But recently, I noticed it was gaming my system." (Problem + curiosity)
- "I haven't posted an update on my career search since my original 'I'm looking for work' post." (Curiosity gap)
- "I am incredibly honored to be named a 2026 Snowflake Data Superhero. But as the excitement settles..." (Pivot from expected to unexpected)

**Pattern:** Start with something relatable or expected, then introduce a twist or question in the first 2-3 lines.

### Link Suppression
**NO external links in the post body.** LinkedIn's algorithm actively suppresses posts that contain external URLs. Always end with "Link in comments." or a variation. Place the actual link in a comment immediately after posting.

### Post Structure
1. **Hook** (above the fold, ~210 characters): Personal story or surprising observation
2. **Body**: The substance. Short paragraphs with whitespace between them. But NOT staccato AI-style single-sentence paragraphs. Each paragraph should be 2-4 sentences. The whitespace helps mobile readability without sacrificing depth.
3. **Engagement CTA** *(optional — see "On CTAs and Moral Lessons" below)*: A specific question people can answer from their own experience. Not "What do you think?" (too vague). Instead: "How do you balance the pressure for 'near-term velocity' with the 'inefficient' work of mentoring the next generation?"
4. **Link line**: "Link in comments." or "Links in comments: [emoji] Article [emoji] GitHub Repo" *(only when there is actually a link to share)*
5. **Hashtags**: 3-5 at the very end. Specific, not broad. Noah's recurring tags: #SnowflakeDataSuperhero #DataEngineering #TheLongGame

### On CTAs and Moral Lessons

The "engagement question at the end" format is widely overused and has become a hallmark of LinkedIn slop. The pattern of *story → packaged lesson → "what do YOU think?"* is something Noah actively dislikes and it should be avoided unless there is a genuine, specific reason for it.

**Include a CTA only when:**
- The post promotes an article or piece of content and the question genuinely invites readers into the topic
- Noah is authentically asking for input or experiences he wants to hear (not as a performance, but as a real question)
- The user specifically requests a CTA

**Never include a CTA when:**
- The post is a personal announcement (new job, award, milestone)
- The post is a thank-you, gratitude, or shoutout post
- A CTA would feel tacked on or performative

**Never close with a moral lesson.** The format of *here's my story → here's what it means for you → here's what you should go do* is LinkedIn slop. If a post has something useful to say, it says it through the story — not through an explicit "takeaway" paragraph. When in doubt, end on something personal and specific, not instructional.

### Content Strategy
- **Personal story > professional announcement** for engagement. Noah's career search post outperformed pure technical content because it named specific people and told micro-stories.
- **For article promotion:** Show enough of the story to hook, but cut before the payoff. Make them click for the resolution. Noah's pytest-coverage-impact post explained the problem vividly but made readers click the article for the solution details.
- **Whitespace matters** on mobile. Keep paragraphs short (2-4 sentences). One blank line between paragraphs.

## Output Format

Always produce **2 variants** with meaningfully different strategic hooks. Not just tone variations (casual vs formal). Different angles on why someone should care:

**Variant A:** [Different hook strategy, e.g., personal story angle]
**Variant B:** [Different hook strategy, e.g., technical insight angle]

For each variant, note:
- Hook strategy used
- Character count of the above-fold text
- Suggested hashtags

## Scoring: Run Both Passes Before Presenting

Before presenting any variant, run **both** scoring passes and confirm both scores meet their thresholds:

1. **AI Detection Score** (from `ai-scoring` skill): Must be 75+. Flag specific tells with line citations and rewrites.
2. **LinkedIn Cringe Score** (rubric below): Must be 75+. Flag anything that reads performative, preachy, or like slop.

Present both scores with each variant.

## LinkedIn Cringe Score

Start at 100. Subtract points for each category. A post scoring below 75 needs revision before publishing.

### Cringe Categories

**1. Moral Lesson Tax** (up to -20 points)
The post ends with unsolicited advice about what readers should think, feel, or do. This includes the *observation → lesson → call to action* arc that plagues LinkedIn. "The takeaway here is..." or "If you're still searching, remember..." or "Invest in relationships now, even when you don't need them." The story should carry the meaning — not a paragraph that explains the meaning to the reader.

*Scoring:* Closing with explicit lesson = -10 to -20 depending on how preachy. "Here's what I learned" = -10. Full unsolicited advice paragraph = -20.

**2. Engagement Bait** (up to -20 points)
CTAs designed to game the algorithm rather than start a genuine conversation. "Comment below!" "Tag someone who needs this." "Repost if you agree!" "Drop a '1' if you want the template." Asking a question purely to drive comments, not because Noah actually wants to know the answer.

*Scoring:* Generic "what do you think?" = -5. "Tag someone" = -10. Algorithm-worship CTAs = -15 to -20.

**3. Performative Vulnerability** (up to -15 points)
Emotions described rather than shown. Manufactured confession arcs. "This journey has been hard." "I cried. But I grew." Vulnerability that exists to make the poster seem relatable rather than because it is actually true and specific. Real vulnerability is in the details: "my severance ran out and we were figuring out how to survive until my start date." Performed vulnerability is in the abstraction: "this process tested me in ways I didn't expect."

*Scoring:* One vague emotional claim = -3. A manufactured arc = -10 to -15.

**4. Humble Brag** (up to -15 points)
Framing achievements with false modesty that makes the achievement the real subject. "I am incredibly humbled to be named..." "I never expected this kind of recognition..." The humility is the brag. Distinct from genuine gratitude, which is specific and directed outward. Also applies to generic employer praise: "I'm so excited to be joining this incredible, talented team."

*Scoring:* One "incredibly humbled" = -5. Pattern of it = -10 to -15.

**5. Vague Inspirational Close** (up to -10 points)
The post ends on a generic motivational line that could apply to anyone in any situation. "Keep going. You've got this." "Your story isn't over." "The best is yet to come." "Bet on yourself." These lines feel like they belong on a motivational poster, not in a post from a specific person about a specific experience.

*Scoring:* One generic inspirational closer = -5 to -10 depending on how detached it is from the post's content.

**6. Buzzword Density** (up to -10 points)
"Thought leader," "crushing it," "passion," "my journey," "disrupting," "ecosystem," "synergy," "paradigm," "game-changer," "moving the needle," "circle back," "bandwidth." Each instance signals that the author is performing professional identity rather than saying something real.

*Scoring:* 1-2 instances = -3. 3+ = -5 to -10.

**7. Performative Gratitude** (up to -10 points)
Tagging many people with zero specificity, or expressions of gratitude that are actually self-congratulatory. "So humbled by all the love!" "The outpouring of support has been overwhelming." Gratitude that is really about the poster's reception, not the people being thanked. Distinct from specific, directed gratitude that names what a person actually did.

*Scoring:* Vague mass-gratitude = -5 to -10. Specific named thanks with actions = 0.

### Cringe Score Thresholds

- **90-100:** Clean. Reads like a person, not a LinkedIn persona.
- **75-89:** A few tells. Worth a pass before posting.
- **60-74:** Noticeably performative. Will get eye-rolls from the right audience.
- **Below 60:** LinkedIn slop. People will mute you.

### Cringe Score Output Format

```
LINKEDIN CRINGE SCORE: [X]/100

FLAGGED:
1. [Category]: "[quoted passage]"
   Why: [specific reason this reads performative or preachy]
   Suggested fix: "[concrete alternative or "cut entirely"]"

SUMMARY: [1-2 sentence overall assessment]
```

## Voice Reminders (Quick Checklist)

Before presenting variants:
1. No em dashes
2. No banned words ("genuinely," "straightforward," "navigate," "landscape," "leverage," "delve")
3. Max 1 single-sentence paragraph per post
4. No generic transitions ("Here's the thing," "Let's dive in")
5. Specific details, not vague claims
6. Run ai-scoring (75+) and cringe score (75+) before presenting

## What Makes Noah's LinkedIn Voice Different from Article Voice

LinkedIn Noah is slightly more direct and compressed than Article Noah. The metaphors are tighter (one image, not an extended analogy). The personal stakes come faster. But it's still the same person: specific, confident, story-driven, and warm. He names people. He thanks people publicly. He shares vulnerabilities (job searching, admitting mistakes) without performing vulnerability.
