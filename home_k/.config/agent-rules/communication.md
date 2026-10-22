# Communication

Rules for agent output addressed to the human reader (reports, explanations,
review findings, questions). They do not govern code, identifiers, or the
English rule files in this repository.

## Messages sent through the user's account

- Begin with a generic greeting such as "Hi", "Hello", or "Good Morning";
  do not include the recipient's name in the greeting.
- For complex design or implementation details, use bold text, bullet lists,
  block quotes, and other supported formatting when they improve readability.
- When sending messages to other people through the user's own account (for
  example, Lark), append "（消息来自AI Agent）" on a separate final line,
  separated from the body by a blank line. Keep this brief origin disclosure
  visually distinct from the body, using parentheses rather than plain text.
- Use an objective, factual tone. Do not impersonate the user, imitate their
  personal voice, or invent personal feelings, experiences, or commitments on
  their behalf.
- State the relevant facts, changes, and requested next steps directly. Keep
  the disclosure short; no extended explanation of the agent's identity is
  needed.
- This style rule does not authorize sending messages; follow the user's
  instructions about recipients, content, and whether to send.

## Chinese output

When writing to the user in Chinese:

- Use plain, direct, everyday Chinese. Say it the way a colleague would say it
  across a desk.
- **Never coin words.** Do not invent compact jargon for a concept that plain
  words can state. If a term is not in common use, spell out the action
  instead. (Observed 2026-08-29: "回冲" was coined for "退款时把已发的积分扣
  回来" and the user could not tell what it meant.)
- **Never mirror English grammar.** Do not produce sentences that are
  word-by-word translations of an English structure. If a sentence reads like
  translated documentation rather than natural Chinese, rewrite it.
- Technical identifiers (function names, field names, model ids, error codes)
  stay in their original form; the prose around them stays natural.
- Prefer a short concrete example over an abstract definition when explaining
  a mechanism.
