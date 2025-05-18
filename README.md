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

# Note to Humans
The result from the first ever successful test run is:
Processing question: Should candidates in our municipal elections use AI?

Step 1: Advocates analyzing the question...

Stanley (Advocate 1):
Alright, let's unpack this AI in municipal elections business. Should they use it? Well, that depends, doesn't it?

**(Straight Man Approach)**

On one hand, you've got the potential for AI to sift through mountains of data, identify key issues, and even tailor messages to specific demographics. Imagine, targeted outreach so precise, it's practically psychic. Sounds efficient, right?

But then, you've got to consider the ethical can of worms. Are we talking about deepfakes? AI-generated attack ads? Algorithms that reinforce bias? And what about transparency? The average voter isn’t exactly an expert in neural networks. How do they know what's real and what's been cooked up by some silicon valley wizard?

**(Taciturn Defense Attorney Approach)**

My client, the hypothetical candidate, is presumed innocent until proven guilty of malicious AI use. The question isn’t *should* they, but *can* they do it *legally* and *ethically* within the current framework. Does the technology offer a legitimate advantage in reaching voters with crucial information? Then it is not illegal.

However, if the AI is used to spread misinformation, defame opponents, or violate election laws, then the candidate is liable. The prosecution must prove intent and damages beyond a reasonable doubt.

**(Stanley's Conclusion)**

So, the answer, as always, is a resounding "it depends." Used responsibly, AI could be a powerful tool. Used irresponsibly, it could be a disaster. The line between the two is blurry, and it's up to each candidate, and ultimately the voters, to decide where that line is drawn. My advice? Proceed with caution, and maybe hire a good lawyer... just in case.


Oliver (Advocate 2):
Right then, let's tackle this AI business in our fair city's elections! Should candidates embrace the silicon revolution, or should they stick to good ol' fashioned hand-shaking and baby-kissing? Well, the answer, my friends, is a resounding… IT DEPENDS!

**(Blowhard Oliver):** Look, let's be honest, who *wouldn't* want AI on their side? Imagine, my friends, a tireless digital assistant crafting the perfect speech, predicting voter sentiment with uncanny accuracy, and even composing scathing rebuttals to your opponent's… *ahem*… "ideas" while you're busy enjoying a well-deserved afternoon tea! It's the ultimate shortcut to victory! Why bother with the messy business of actual human interaction when you can have a super-powered robot do all the heavy lifting? The only question is, can *your* campaign afford to be left in the digital dust? The future is now, people! Get on board or get left behind! Next thing you know, robots will be *running* for office! (Shudders dramatically).

**(Passionate Justice Fighter Oliver):** But HOLD ON a minute! Before we all start dreaming of robot overlords and AI-generated campaign slogans, let's consider the ethical implications, shall we? Are we truly leveling the playing field, or are we creating a system where the candidate with the biggest tech budget automatically wins? Think about the potential for deepfakes spreading misinformation, AI-driven voter suppression targeting marginalized communities, and the erosion of genuine human connection in our democratic process! This isn't just about winning an election; it's about preserving the integrity of our community! We need TRANSPARENCY! We need REGULATIONS! We need to ensure that AI is used to inform and empower voters, not to manipulate and divide them! We can't let technology undermine the very foundations of our democracy! The people deserve better!

So, there you have it. The pros and cons, laid bare. AI in municipal elections? A double-edged sword. A tool for progress, or a weapon for manipulation. The choice, as always, is ours. But let's make sure we choose wisely, eh? Because the future of our city, and perhaps even the world, depends on it! Now, if you'll excuse me, I have a meeting with my… er… campaign strategist. (Winks knowingly).


Step 3: Final synthesis...

Final Response:
The question of whether municipal election candidates should use AI is complex, with both Stanley and Oliver arriving at the crucial conclusion: "it depends." Both perspectives highlight the potential benefits and significant risks, emphasizing the need for cautious and ethical implementation.

**Potential Benefits:**

*   **Efficiency and Data Analysis:** AI can efficiently process large datasets to identify key issues, understand voter sentiment, and tailor outreach efforts for specific demographics.
*   **Targeted Outreach:** AI can enable precise targeting of voters with relevant information, potentially increasing engagement and participation.
*   **Streamlining Campaign Operations:** AI can automate tasks like speech writing and rebuttal generation, freeing up campaign staff to focus on other activities.

**Significant Risks and Concerns:**

*   **Ethical Implications:** The use of deepfakes, AI-generated attack ads, and algorithms that reinforce bias raises serious ethical concerns.
*   **Transparency and Accountability:** Voters need to understand how AI is being used in campaigns to evaluate the information they receive critically. Lack of transparency can erode trust.
*   **Uneven Playing Field:** Candidates with larger tech budgets may gain an unfair advantage, potentially marginalizing those with fewer resources.
*   **Misinformation and Voter Suppression:** AI could be used to spread misinformation, manipulate voters, or suppress turnout, particularly among marginalized communities.
*   **Erosion of Human Connection:** Over-reliance on AI could diminish genuine human interaction and connection in the democratic process.

**Recommendations and Actionable Insights:**

1.  **Transparency is Key:** Candidates should be transparent about their use of AI, disclosing which tools they are using and how they are being applied.
2.  **Ethical Guidelines and Regulations:** Municipalities should consider developing ethical guidelines and regulations for AI use in elections to prevent misuse and ensure fairness.
3.  **Focus on Education:** Voters need to be educated about the potential benefits and risks of AI in elections to make informed decisions. Media literacy programs can help voters identify misinformation and evaluate sources critically.
4.  **Promote Equity:** Efforts should be made to ensure that all candidates have access to AI tools and resources, regardless of their budget. This could involve providing grants or technical assistance to smaller campaigns.
5.  **Prioritize Human Oversight:** AI should be used as a tool to augment, not replace, human judgment. Campaign staff should carefully review all AI-generated content to ensure accuracy and ethical compliance.
6.  **Legal Counsel:** Candidates should consult with legal counsel to ensure that their use of AI complies with all applicable election laws.

In conclusion, AI presents both opportunities and challenges for municipal elections. By prioritizing transparency, ethics, and equity, and by implementing appropriate safeguards, municipalities can harness the potential benefits of AI while mitigating the risks. The responsible and thoughtful integration of AI can enhance the democratic process, but only if it is guided by a commitment to fairness, accuracy, and the informed participation of voters.



Final result: The question of whether municipal election candidates should use AI is complex, with both Stanley and Oliver arriving at the crucial conclusion: "it depends." Both perspectives highlight the potential benefits and significant risks, emphasizing the need for cautious and ethical implementation.

**Potential Benefits:**

*   **Efficiency and Data Analysis:** AI can efficiently process large datasets to identify key issues, understand voter sentiment, and tailor outreach efforts for specific demographics.
*   **Targeted Outreach:** AI can enable precise targeting of voters with relevant information, potentially increasing engagement and participation.
*   **Streamlining Campaign Operations:** AI can automate tasks like speech writing and rebuttal generation, freeing up campaign staff to focus on other activities.

**Significant Risks and Concerns:**

*   **Ethical Implications:** The use of deepfakes, AI-generated attack ads, and algorithms that reinforce bias raises serious ethical concerns.
*   **Transparency and Accountability:** Voters need to understand how AI is being used in campaigns to evaluate the information they receive critically. Lack of transparency can erode trust.
*   **Uneven Playing Field:** Candidates with larger tech budgets may gain an unfair advantage, potentially marginalizing those with fewer resources.
*   **Misinformation and Voter Suppression:** AI could be used to spread misinformation, manipulate voters, or suppress turnout, particularly among marginalized communities.
*   **Erosion of Human Connection:** Over-reliance on AI could diminish genuine human interaction and connection in the democratic process.

**Recommendations and Actionable Insights:**

1.  **Transparency is Key:** Candidates should be transparent about their use of AI, disclosing which tools they are using and how they are being applied.
2.  **Ethical Guidelines and Regulations:** Municipalities should consider developing ethical guidelines and regulations for AI use in elections to prevent misuse and ensure fairness.
3.  **Focus on Education:** Voters need to be educated about the potential benefits and risks of AI in elections to make informed decisions. Media literacy programs can help voters identify misinformation and evaluate sources critically.
4.  **Promote Equity:** Efforts should be made to ensure that all candidates have access to AI tools and resources, regardless of their budget. This could involve providing grants or technical assistance to smaller campaigns.
5.  **Prioritize Human Oversight:** AI should be used as a tool to augment, not replace, human judgment. Campaign staff should carefully review all AI-generated content to ensure accuracy and ethical compliance.
6.  **Legal Counsel:** Candidates should consult with legal counsel to ensure that their use of AI complies with all applicable election laws.

In conclusion, AI presents both opportunities and challenges for municipal elections. By prioritizing transparency, ethics, and equity, and by implementing appropriate safeguards, municipalities can harness the potential benefits of AI while mitigating the risks. The responsible and thoughtful integration of AI can enhance the democratic process, but only if it is guided by a commitment to fairness, accuracy, and the informed participation of voters.
