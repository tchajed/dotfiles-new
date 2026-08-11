# Pi subagent extension

This is the official subagent example vendored from
`@earendil-works/pi-coding-agent` 0.84.1 (`examples/extensions/subagent`).

Agent definitions are installed from `pi/agents/`, and workflow prompts are
installed from `pi/prompts/`. The agents use the OpenAI Codex subscription
models enabled in `pi/settings.json`:

- `scout` and `explorer`: `openai-codex/gpt-5.6-terra`
- `planner`, `reviewer`, and `worker`: `openai-codex/gpt-5.6-sol`

`pi-dynamic-workflows` is installed separately through the package list in
`pi/settings.json`; its child agents inherit the active parent model.
