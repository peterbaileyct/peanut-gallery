# Purpose
This is a Flutter application for MacOS, iOS, and Android, that allows a user to ask a question of an orchestrated set of Personas using Large Language Models. It uses the Google Gemini API.

## Generated Files:
- lib/main.dart: The main entry point for the Flutter application.
- lib/services/storage_service.dart: Handles local storage for Personas and API keys.
- lib/ui/widgets/persona_editor.dart: Widget for editing the user's persona.
- lib/ui/widgets/conversation_display.dart: Widget for displaying conversation output.
- lib/ui/widgets/persona_selector.dart: Widget for selecting personas as advocates or jury.
- lib/ui/widgets/api_key_dialog.dart: Dialog for entering the Gemini API key.
- lib/models/persona.dart: Data model for persona objects.
- lib/bs_ns_controller.dart: Manages the invocation and interaction with the BS-NS process.
- pubspec.yaml: Updated with required dependencies.

## Data Types
A Persona is a combination of a name and a Mission Statement, which is a long-form description of a person's goals and intentions. More details are in persona.few.md.

## Startup
A Google Gemini API key is required. If one already exists in secure local storage, then it will be used. If not, the user will be prompted to provide one.
If no Personas exist in local storage, the following two will be created:
- Stanley, who is: "A comedic straight man or a taciturn defense attorney, as the situation demands."
- Oliver, who is: "A humorously exaggerated blowhard or a passionate fighter for justice, as the situation demands."

If the user's Persona has not been defined, it will be initialized as: Puddin' Tame / "I am a good dude and/or a strong lady and I have some questions."


## Main UI
The main UI is a window that allows the user to enter a Name and Mission Statement for their Persona on the left side. These changes will be stored locally and loaded at app start. The right side is a large, scrolling text block that displays the prompts and outputs of each LLM used. A button in the top-right corner can be used to enter a new Google Gemini API key. At the bottom, a long multi-line text input can be used for the user to enter a question. On the right side, the names of available Personas other than the user are listed. They can be dragged into boxes for Advocates and Jury. The "Ask" button on the right side of the question box is disabled if the user persona settings are blank or there are not two Advocate personas selected.
A user can select up to twelve Personas to comprise a Jury.
A user can ask a question by typing or pasting it into a text area and clicking an "Ask" button or hitting Cmd-Enter.
A button next to the "available personas" display opens a separate window in which the user can add, remove, and update Personas.

## Question Process
When a question is asked, an instance of the BS-NS process defined in bs-ns.few.md will be launched. The LLM prompts and responses logged by BS-NS will be displayed in the main text area.