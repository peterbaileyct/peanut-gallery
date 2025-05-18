# BS-NS: Boss of the Negotiation System

## Generated Files:
- lib/bs_ns.dart: Implements the BS-NS orchestration logic.

BS-NS is a non-AI subsystem that orchestrates control between the LLMs representing the Advocates and uses further LLM sessions to condense and parse information to aid in this orchestration. BS-NS needs a Gemini API key in order to operate, as well as a user Persona, two Advocate Personas, and optionally between 1 and 12 Jury personas. Each prompt and response from the LLMs used should be output for logging purposes, to be consumed by the code that invokes BS-NS.

## Mediation
When the user asks a question, BS-NS will do the following:
- If a jury has been selected, begin an LLM session with Google Gemini. Prompt this session, "Please generate a short summary of the members of a simulated mediation jury.", followed by a list of the names and mission statements of all the jurors. This is the "jury report".
- Begin a separate LLM session for each Advocate by indicating: "You are playing the role of a conflict mediator. Your name is [name]. Your mission statement is: [Mission Statement]. Your goal is to seek a peaceful resolution. When you feel that a peaceful resolution has been identified, you will end your message with the word RESOLVED in a single line in all capitals."
- If a jury was chosen:
  - Tell the advocates: "There is a jury for this dispute. You are encouraged to discuss the matter in terms that will be meaningful to them. They are:" followed by a full list of the names and mission statements of the jury.
- Tell the advocates: "[Name of user persona] brings you a matter to resolve. Their mission statement is: [Mission Statement]. They ask: [question]"
- Until either both advocates have ended their message with RESOLVED or ten iterations have passed, tell each advocate what the other said.
- If both said "RESOLVED", start a new LLM session and have it generate a summary of the resolution based on the user's mission statement.
- Otherwise, indicate that no resolution could be found and this matter should be brought to the attention of carbon-based life forms.