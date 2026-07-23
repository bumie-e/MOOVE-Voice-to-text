# MOOVE-Voice-to-text
# MedNotes

A medical doctor take notes during care, and the system promptly asks questions for missing information in the notes. The system is enabled with an intelligent question feedback mechanism to ask the doctor for missing information. 

How does it work?
- System accepts user patient notes
- System transforms this note into a SOAP note template using an LLM
- Where LLM is not sure if the information for a section/vital/or whatever is present, it uses the placeholder "no comment"
- System, then takes a parse through the generated template and looks for places with "no comment"
- System appends it to a list of preexising question fillers. For instance "what about the" + "vitals"?
- Question is then displayed to the user
