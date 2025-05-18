``` This information is primarily for carbon-based life forms. Instructions for Large Language Models can be found in PARSEME.md ```

# peanut-gallery
A dispute resolution system using orchestrated AI.

## Operation
- The user has a "persona" defined as a name and a "mission statement" describing who they are, as a general context for questions. If none has yet been provided, it defaults to "I am a good dude and/or a strong lady and I have some questions." The default name is Puddin' Tame.
- The user can update their persona in the main UI; the updates are written to and read from local storage.
- The user can define any number of personas.
- Personas are stored locally. They consist of a name and a mission statement.
- Pefore asking a question, the user must choose two advocates, who are Personas responsible for helping to mediate the issues.
- The advocates are defined using their own "mission statements" and given names, which are also user-configurable and written to local storage.
- The default advocates are:
- Stanley, who is: "A comedic straight man or a taciturn defense attorney, as the situation demands."
- Oliver, who is: "A humorously exaggerated blowhard or a passionate fighter for justice, as the situation demands."
- All other personas are user-generated.
- A user can select up to twelve Personas to comprise a Jury.
- A user can ask a question by typing or pasting it into a text area and clicking an "Ask" button or hitting Cmd-Enter.
- When a question is asked, control is yielded to a non-AI subsystem called BS-NS (for "Boss of the Negotiation System"). The following actions are taken by BS-NS:
- If a jury has been selected, begin an LLM session, e.g. Google Gemini or ChatGPT. Prompt this session, "Please generate a short summary of the members of a simulated mediation jury.", followed by a list of the names and mission statements of all the jurors. This is the "jury report".
- Begin a separate LLM session for each Advocate by indicating: "You are playing the role of a conflict mediator. Your name is [name]. Your mission statement is: [Mission Statement]. Your goal is to seek a peaceful resolution. When you feel that a peaceful resolution has been identified, you will end your message with the word RESOLVED in a single line in all capitals."
- If a jury was chosen:
- Tell the advocates: "There is a jury for this dispute. You are encouraged to discuss the matter in terms that will be meaningful to them. They are:" followed by a full list of the names and mission statements of the jury.
- Tell the advocates: "[Name of user persona] brings you a matter to resolve. Their mission statement is: [Mission Statement]. They ask: [question]"
- Until either both advocates have ended their message with RESOLVED or ten iterations have passed, tell each advocate what the other said.
- If both said "RESOLVED", start a new LLM session and have it generate a summary of the resolution based on the user's mission statement.
- Otherwise, indicate that no resolution could be found and this matter should be brought to the attention of carbon-based life forms.
