---
description: Conduct an end-of-day review to capture progress and set up tomorrow.
argument-hint: [file or folder path]
allowed-tools: Read, Write, Edit, Glob
---

You will conduct an end-of-day review to capture progress and set up tomorrow.
You can also utilize the todoist command which leverages the todoist-mcp to integrate with Todoist tasks. This can mean
tracking completed tasks or adding new tasks based on your review.

## Review Process

1. **Today's Activity**
   - Find all notes modified today
   - Identify new notes created
   - Review work across all projects
   - If notes were modified by moving them to the Archive, do not include them in today's review.

2. **Progress Assessment**
   - What was accomplished?
   - What got stuck or blocked?
   - What unexpected discoveries emerged?

3. **Capture Insights**
   - Key learnings from today
   - New connections discovered
   - Questions that arose

4. **Tomorrow's Setup**
   - Top 3 priorities
   - Open loops to close
   - Questions to explore

## Output Format

Create or update a daily note with:

```markdown
# Daily Review - [Date]

## Accomplished

- ✓ [Completed item 1]
- ✓ [Completed item 2]

## Progress Made

- [Project/Area]: [What moved forward]
- [Project/Area]: [What moved forward]

## Insights

- [Key realization or connection]
- [Important learning]

## Blocked/Stuck

- [What didn't progress and why]

## Discovered Questions

- [New question that emerged]
- [Thing to research]

## Tomorrow's Focus

1. [Priority 1]
2. [Priority 2]
3. [Priority 3]

## Open Loops

- [ ] [Thing to remember]
- [ ] [Person to follow up with]
- [ ] [Idea to develop]
```

## Additional Actions

- Link related discoveries
