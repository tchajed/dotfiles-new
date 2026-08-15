import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const THINKING_LEVELS = ["off", "minimal", "low", "medium", "high", "xhigh", "max"] as const;
const SELECTABLE_THINKING_LEVELS = ["off", "low", "medium", "high", "xhigh"] as const;
type ThinkingLevel = (typeof THINKING_LEVELS)[number];

function isThinkingLevel(value: string): value is ThinkingLevel {
  return THINKING_LEVELS.includes(value as ThinkingLevel);
}

export default function (pi: ExtensionAPI) {
  pi.registerCommand("effort", {
    description: "Set the thinking level",
    getArgumentCompletions: (prefix) => {
      const normalizedPrefix = prefix.trim().toLowerCase();
      const matches = THINKING_LEVELS.filter((level) => level.startsWith(normalizedPrefix));
      return matches.length > 0 ? matches.map((level) => ({ value: level, label: level })) : null;
    },
    handler: async (args, ctx) => {
      let requested = args.trim().toLowerCase();

      if (!requested) {
        const current = pi.getThinkingLevel();
        const selected = await ctx.ui.select(
          `Thinking effort (current: ${current})`,
          [...SELECTABLE_THINKING_LEVELS],
        );
        if (!selected) return;
        requested = selected;
      }

      if (!isThinkingLevel(requested)) {
        ctx.ui.notify(
          `Unknown effort "${requested}". Choose: ${THINKING_LEVELS.join(", ")}`,
          "error",
        );
        return;
      }

      pi.setThinkingLevel(requested);
      const applied = pi.getThinkingLevel();

      if (applied !== requested) {
        ctx.ui.notify(
          `This model does not support ${requested} effort; using ${applied}`,
          "warning",
        );
        return;
      }

      ctx.ui.notify(`Thinking effort set to ${applied}`, "info");
    },
  });
}
