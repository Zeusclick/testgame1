# Cosmic Catch – Auto-Driven Cursor Repo

This repo is prepared so that a Cursor Agent can autonomously build a Tier-1 iOS game called **Cosmic Catch**.

## How to Use

1. Clone this repo into Cursor (or create a new Git repo from these files and then clone).
2. Open the workspace in Cursor.
3. Start the Agent with a simple prompt, for example:

   > You are working in the Cosmic Catch repo.  
   > Read docs/project_config.md, docs/implementation_plan.md, docs/implementation_state.md, and then follow .cursorrules.  
   > Start from the Current Step in implementation_state.md and proceed through tasks in order.

The rules in `.cursorrules` will force the Agent into **automatic continuous mode**, executing several tasks per run and updating `implementation_state.md` as it goes.
