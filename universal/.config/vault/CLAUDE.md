# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Vault Overview

This is an Obsidian personal knowledge management vault organized using a PARA-inspired structure:

- **00 - Inbox**: Temporary notes and quick captures awaiting processing
- **01 - Projects**: Active projects with defined outcomes and timelines
- **02 - Areas**: Ongoing responsibilities and areas of interest
- **03 - Resources**: Reference materials, ideas, and research
- **04 - Archives**: Completed or inactive projects
- **05 - Attachments**: Binary files (Excalidraw drawings, Ink notes)
- **06 - Metadata**: Templates and vault infrastructure

## Custom Commands

The `.claude/commands/` directory contains specialized slash commands:

### `/daily-kickoff`

Creates a new daily note and captures the intended focus for the day:

- Sets clear intentions and priorities for the day ahead
- Identifies key focus areas based on ongoing projects and tasks
- **May use Todoist integration** to pull in tasks or add new ones

**Output**: Creates a daily note with focus areas and priorities

**Allowed tools**: Read, Write, Edit, Glob

### `/daily-review`

Conducts end-of-day reviews by:

- Finding notes modified today
- Assessing progress and insights
- Capturing blockers and discoveries
- Setting up tomorrow's priorities
- **May use Todoist integration** to track or add tasks based on review

**Output**: Creates/updates a daily note with structured review format

### `/thinking-partner`

Facilitates collaborative exploration of complex problems:

- Asks clarifying questions before jumping to solutions
- Searches vault for relevant existing notes
- Tracks insights and connections during discussion
- Creates note in "00 - Inbox" to capture conversation context
- Focuses on exploration over solutioning

### `/todoist`

Creates bi-directional links between vault notes and Todoist tasks:

- Converts note content into appropriate Todoist tasks
- Uses completed Todoist tasks to inform daily/project notes
- **Ignores Inbox tasks** (unprocessed items)
- Only examines tasks assigned to specific projects

**Uses**: `todoist-mcp` tools for integration

### `/add-frontmatter`

Adds intelligent YAML frontmatter to Obsidian notes:

- Analyzes content to determine note type (meeting, daily, reference, project)
- Adds type-appropriate properties (date, attendees, status, tags, etc.)
- Generates titles for untitled notes
- Fixes deprecated formats (`tag` → `tags`, `alias` → `aliases`)
- Maintains consistency across similar notes

**Allowed tools**: Read, Write, Edit, Glob

## Templates

**Daily Note Template** (`06 - Metadata/Templates/Daily note.md`):

- Uses Templater plugin syntax (`tp.file.title`, `moment()`)
- Includes: Summary, Tasks, Meetings, Artifacts, Scratchpad sections
- Links to weekly notes in `01 - Calendar/Weekly Notes/`

## Obsidian Integration

This vault uses:

- **Templater**: For dynamic template variables
- **Todoist plugin**: Token stored in `.obsidian/todoist-token`
- **Daily notes**: Configured in `.obsidian/daily-notes.json`
- **Community plugins**: See `.obsidian/community-plugins.json` for active plugins

## Working with Notes

When creating or editing notes:

1. Place new notes in appropriate PARA category
2. Use Templater syntax for dynamic content: `<% ... %>`
3. Use YAML frontmatter for metadata (title, type, tags, status, etc.)
4. Link related notes using `[[Note Name]]` syntax
5. Use `"[[Note Name]]"` format for links in frontmatter properties

## Todoist Integration Pattern

When working with tasks:

- Use `mcp__todoist__*` tools for Todoist operations
- Skip tasks in Todoist Inbox project
- Maintain consistency between vault notes and Todoist project structure
- Prefer bi-directional updates (notes ↔ tasks)
