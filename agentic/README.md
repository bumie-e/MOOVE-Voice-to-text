# MOOVE-Voice-to-text - Agentic AI

## About

This section of the code focuses on the Agentic AI system responsible for processign the transcripts gotten from the speech to text system, and produces either a question for the doctor or a complete formatted medical note.

### Story

A medical doctor take notes during care, and the system promptly asks questions for missing information in the notes. The system is enabled with an intelligent question feedback mechanism to ask the doctor for missing information. 

### How does it work?
- System accepts user patient notes
- System transforms this note into a SOAP note template using an LLM
- Where LLM is not sure if the information for a section/vital/or whatever is present, it uses the placeholder "no comment"
- System, then takes a parse through the generated template and looks for places with "no comment"
- System appends it to a list of preexising question fillers. For instance "what about the" + "vitals"?
- Question is then displayed to the user


>Please note that SOAP note template used here is only as a proof of concept. The medical note template to be used will be provided by the clinical team.


## Architecture Stages
This part documents how the final architecture came to be. Three stages of design were involved with the central aim on scalability and concurrency.

### Stage 1

Multi-Agent Orchestration

This architecture aims to treat each component as an agent. The orchestator agent (series of python automation scripts) schedules and handles concurrent requests and assignments to the other agents. It also manages the state of each agent object.

                    [Orchestrator Agent]
                   /         |          \
                  /          |           \
     [STT Agent]   [SOAP Writer Agent]  [Validator Agent]
         |                  |                   |
    Transcribes       Drafts each           1. Checks each
    voice input       SOAP section          section for
    (multilingual)    independently         missing information
                                                |
                                            2. Generates targeted,
                                            clinically-phrased
                                            questions for doctor
                                                |
                                            [Doctor UI]
                                                │
                                            Answers fed back to
                                            Orchestrator → loop

### Stage 2
Structured Output + Tool-Calling Agent

This architecture dives into the writer and validator component and define the interactions between the LLM and the tools

```

[Raw Doctor Notes]
      │
      │
[LLM with Structured Output]   ← returns a typed SOAP object
      │                           e.g. { subjective: "...",
      │                                  objective: null,
      │                                  assessment: "..." }
      │
[Agent with Tools]
      │
      ├── tool: validate_section(section, content)
      │         → LLM judges if content is clinically sufficient
      │
      ├── tool: ask_doctor(question)
      │         → surfaces question to UI, awaits answer
      │
      ├── tool: fill_section(section, new_content)
      │         → writes answer into the SOAP object
      │
      └── tool: finalize_note()
                → triggers when all sections pass validation
```

### Stage 3
Full architecture. It separates 

```
[Raw Doctor Notes]
        │
        │
[Orchestrator]  (holds shared SOAP state object)
     │                              │
     │                              │
[SOAP Writer Agent]          [Validator Agent]
     │                              │
     ├── tool: write_section()      ├── tool: validate_section()
     ├── tool: update_section()     ├── tool: get_question()
     ├── tool: flag_uncertain()     └── tool: ask_doctor()
     └── tool: read_notes()         
```
**The flow:**

1. Orchestrator → SOAP Writer Agent
        Writer reads raw notes
        Calls write_section() for confident fields
        Calls flag_uncertain(section, reason) for gaps

2. Orchestrator → Validator Agent  (passes partial SOAP + flags)
        Validator calls validate_section() on each field
        If gap found → calls get_question(gap)
        Then calls ask_doctor(question)
        
3. Doctor answers
        
4. Orchestrator → SOAP Writer Agent  (passes doctor's answer + section context)
        Writer calls update_section() — finds the gap and fills it in. 
        Optional, revalidate response. Writer may call flag_uncertain() again to check for ambuiguity.
        
5. Orchestrator → Validator Agent  (re-validates updated section)
        If valid → moves to next gap
        If still incomplete → loops back to step 3
        When all sections pass → calls finalize_note()
       
6. Final SOAP Note
7. Use finalize_note() step to end the process


## Directory Structure
This helps to separate concerns cleanly

```
agentic/
├── agents/
│   ├── __init__.py
│   ├── base.py             ← abstract Agent class all agents inherit
│   ├── orchestrator.py
│   ├── soap_writer.py
│   └── validator.py
├── tools/
│   ├── __init__.py
│   ├── base.py             ← abstract Tool class
│   ├── soap/
│   │   ├── write_section.py
│   │   ├── update_section.py
│   │   ├── flag_uncertain.py
│   │   └── read_notes.py
│   └── validation/
│       ├── validate_section.py
│       ├── get_question.py
│       ├── ask_doctor.py
│       └── finalize_note.py
├── state/
│   ├── soap_note.py        ← SOAP state object
│   └── session.py          ← session-level state (doctor, patient, history)
├── prompts/
│   ├── soap_writer.py
│   └── validator.py
├── config/
│   └── llm.py              ← model config, client setup
├── main.py
└── __init__.py

```