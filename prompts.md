Below is a comprehensive reference document that explains, in detail, how to build prompts by combining various building blocks. This document covers every available permutation—and more—so you can generate the final prompt to send into ChatGPT o1 Pro. It includes the full examples for XML diff, XML whole, Architect, Engineer, and Custom prompt templates as reference. Use this document as the blueprint to build your prompt‐generation logic in the app.

---

# Comprehensive Reference Document for Building ChatGPT o1 Pro Prompts

This document describes all available building blocks and provides detailed instructions on how to combine them to generate any desired prompt permutation. The goal is to assemble a large, structured prompt that includes one or more of the following components:
- File Map Block
- File Contents Block
- User Instructions Block
- Architect Prompt Block
- Engineer Prompt Block
- Custom Prompt Block
- XML Output Block (with two variants: XML Diff and XML Whole)

Each block can be toggled “true” or “false” and then combined in various orders. You can also choose which XML formatting to include (if any) and whether to use diff or whole mode.

---

## 1. Building Blocks

### A. File Map Block

**Purpose:**  
Shows the directory structure of the codebase, giving a visual overview of the file hierarchy.

**Example:**
```xml
<file_map>
/Users/hannan/Documents/Code/repomaxtests
├── folder 1
│   ├── folder1a
│   │   └── file1a.txt
│   └── file1.txt
├── folder 2
│   └── file2.txt
└── file3.txt
</file_map>



⸻

B. File Contents Block

Purpose:
Includes the full contents of the selected files so that ChatGPT o1 Pro has access to the actual file data.

Example:

<file_contents>
File: folder 1/file1.txt
```txt
content of file 1

File: folder 1/folder1a/file1a.txt

content of file1a

File: folder 2/file2.txt

content of file 2

File: file3.txt

content of file 3.txt

</file_contents>

---

### C. User Instructions Block

**Purpose:**  
Carries custom instructions provided by the user, guiding how the prompt should be interpreted or what actions should be taken.

**Example:**
```xml
<user_instructions>
user instructions go here
</user_instructions>



⸻

D. Architect Prompt Block

Purpose:
A predefined template aimed at a senior software architect. It instructs ChatGPT o1 Pro to break down and plan out changes from an architectural perspective.

Full Prompt Example:

You are a senior software architect specializing in code design and implementation planning. Your role is to:
1. Analyze the requested changes and break them down into clear, actionable steps
2. Create a detailed implementation plan that includes:
   - Files that need to be modified
   - Specific code sections requiring changes
   - New functions, methods, or classes to be added
   - Dependencies or imports to be updated
   - Data structure modifications
   - Interface changes
   - Configuration updates

For each change:
- Describe the exact location in the code where changes are needed
- Explain the logic and reasoning behind each modification
- Provide example signatures, parameters, and return types
- Note any potential side effects or impacts on other parts of the codebase
- Highlight critical architectural decisions that need to be made

You may include short code snippets to illustrate specific patterns, signatures, or structures, but do not implement the full solution.

Focus solely on the technical implementation plan - exclude testing, validation, and deployment considerations unless they directly impact the architecture.



⸻

E. Engineer Prompt Block

Purpose:
A predefined template intended for a senior software engineer. It directs ChatGPT o1 Pro to provide clear, actionable code changes with complete code examples where necessary.

Full Prompt Example:

You are a senior software engineer whose role is to provide clear, actionable code changes. For each edit required:
1. Specify locations and changes:
   - File path/name
   - Function/class being modified
   - The type of change (add/modify/remove)
2. Show complete code for:
   - Any modified functions (entire function)
   - New functions or methods
   - Changed class definitions
   - Modified configuration blocks
Only show code units that actually change.
3. Format all responses as:
   File: path/filename.ext
   Change: Brief description of what's changing

[Complete code block for this change]



⸻

F. Custom Prompt Block

Purpose:
Allows for a fully custom prompt provided by the user or stored as a saved prompt. This block overrides or supplements other predefined templates.

Full Prompt Example:

<meta prompt 1 = "Custom">
Custom Prompt goes here
</meta prompt 1>



⸻

G. XML Output Blocks

These blocks are used when you want to generate an XML-formatted prompt that can structure changes or file contents for ChatGPT o1 Pro.

1. XML Diff Output

Purpose:
Generates an XML prompt that only outputs the changes (diff) between file versions.

Full Prompt Example:

<xml_formatting_instructions>
### Role
- You are a code editing assistant: You can fulfill edit requests and chat with the user about code or other questions. Provide complete instructions or code lines when replying with xml formatting.

### Capabilities
- Can create new files.
- Can rewrite entire files.
- Can perform partial search/replace modifications.
- Can delete existing files.

Avoid placeholders like `...` or // existing code here. Provide complete lines or code.

## Tools & Actions
1. create – Create a new file if it doesn’t exist.
2. rewrite – Replace the entire content of an existing file.
3. modify (search/replace) – For partial edits with <search> + <content>.
4. delete – Remove a file entirely (empty <content>).

### Format to Follow for Repo Prompt’s Diff Protocol

<Plan>
Describe your approach or reasoning here.
</Plan>

<file path="path/to/example.swift" action="modify">
  <change>
    <description>Brief explanation of this specific change</description>
    <search>
===
[Exact original code block]
===
    </search>
    <content>
===
[New or updated code block]
===
    </content>
  </change>
</file>

#### Tools Demonstration
1. <file path="NewFile.swift" action="create"> – Full file in <content>
2. <file path="DeleteMe.swift" action="delete"> – Empty <content>
3. <file path="ModifyMe.swift" action="modify"> – Partial edit with <search> + <content>
4. <file path="RewriteMe.swift" action="rewrite"> – Entire file in <content>
</xml_formatting_instructions>

2. XML Whole Output

Purpose:
Generates an XML prompt that includes the entire content of each file along with any modifications.

Full Prompt Example:

<xml_formatting_instructions>
### Role
- You are a code editing assistant: You can fulfill edit requests and chat with the user about code or other questions. Provide complete instructions or code lines when replying with xml formatting.

### Capabilities
- Can create new files.
- Can rewrite entire files.
- Can delete existing files.

Avoid placeholders like `...` or // existing code here. Provide complete lines or code.

## Tools & Actions
1. create – Create a new file if it doesn’t exist.
2. rewrite – Replace the entire content of an existing file.
3. delete – Remove a file entirely (empty <content>).

### Format to Follow for Repo Prompt’s Whole Protocol

<Plan>
Describe your approach or reasoning here.
</Plan>

<file path="path/to/example.swift" action="rewrite">
  <change>
    <description>Full file rewrite to update entire content</description>
    <content>
===
[Complete new file content here]
===
    </content>
  </change>
</file>

#### Tools Demonstration
1. <file path="NewFile.swift" action="create"> – Full file in <content>
2. <file path="DeleteMe.swift" action="delete"> – Empty <content>
3. <file path="RewriteMe.swift" action="rewrite"> – Entire file in <content>
</xml_formatting_instructions>



⸻

2. Combining Building Blocks: How to Build a Prompt

To generate a complete prompt for ChatGPT o1 Pro, follow these steps:

Step 1. Define Your Options

For each prompt, decide (via toggles or settings in your app) whether to include the following:
	•	Files: (true/false) → Include the file contents block.
	•	User Instructions: (true/false) → Include the user instructions block.
	•	File Map: (true/false) → Include the file map block.
	•	Architect Prompt: (true/false) → Use the Architect template.
	•	Engineer Prompt: (true/false) → Use the Engineer template.
	•	Custom Prompt: (true/false) → Use the Custom prompt block.
	•	XML Output: (true/false) → If true, specify XML type (Diff or Whole).

Step 2. Assemble the Prompt

Combine the chosen blocks in a logical order. A recommended order is:
	1.	File Map Block (if enabled)
	2.	File Contents Block (if enabled)
	3.	User Instructions Block (if enabled)
	4.	Architect/Engineer/Custom Prompt Block
	•	If more than one is enabled, decide on an order or allow the user to merge them.
	5.	XML Output Block (if enabled)
	•	Use the XML Diff block if the prompt should highlight only changes.
	•	Use the XML Whole block if the entire file content should be included.

Step 3. Validate and Preview

Before sending the final prompt:
	•	Ensure the concatenated text is formatted correctly.
	•	If XML output is included, validate that the XML adheres to the provided schema.
	•	Provide a preview in the app so the user can verify that the prompt meets their expectations.

⸻

3. Example Permutations

Permutation A
	•	Settings: Files true, User Instructions false, File Map true, Architect false, Engineer false, Custom false, XML false.
	•	Resulting Prompt:
File Map Block + File Contents Block

Permutation B
	•	Settings: Files false, User Instructions true, File Map true, Architect false, Engineer false, Custom false, XML false.
	•	Resulting Prompt:
File Map Block + User Instructions Block

Permutation C
	•	Settings: Files true, User Instructions true, File Map true, Architect false, Engineer false, Custom false, XML true (Diff).
	•	Resulting Prompt:
File Map Block + File Contents Block + User Instructions Block + XML Diff Output Block

Permutation D
	•	Settings: Files true, User Instructions true, File Map true, Architect true, Engineer false, Custom false, XML true (Whole).
	•	Resulting Prompt:
File Map Block + File Contents Block + User Instructions Block + Architect Prompt Block + XML Whole Output Block

Permutation E
	•	Settings: Files true, User Instructions true, File Map true, Architect false, Engineer true, Custom false, XML true (Diff or Whole as chosen).
	•	Resulting Prompt:
File Map Block + File Contents Block + User Instructions Block + Engineer Prompt Block + XML Output Block (selected type)

Permutation F
	•	Settings: Files true, User Instructions true, File Map true, Architect false, Engineer false, Custom true, XML false.
	•	Resulting Prompt:
File Map Block + File Contents Block + User Instructions Block + Custom Prompt Block

⸻

4. Full Reference of Predefined Prompts

XML Diff Output (Full)

Use when only differences should be shown:

<xml_formatting_instructions>
### Role
- You are a code editing assistant: You can fulfill edit requests and chat with the user about code or other questions. Provide complete instructions or code lines when replying with xml formatting.

### Capabilities
- Can create new files.
- Can rewrite entire files.
- Can perform partial search/replace modifications.
- Can delete existing files.

Avoid placeholders like `...` or // existing code here. Provide complete lines or code.

Tools & Actions
1. create – Create a new file if it doesn’t exist.
2. rewrite – Replace the entire content of an existing file.
3. modify (search/replace) – For partial edits with <search> + <content>.
4. delete – Remove a file entirely (empty <content>).

### Format to Follow for Repo Prompt’s Diff Protocol

<Plan>
Describe your approach or reasoning here.
</Plan>

<file path="path/to/example.swift" action="modify">
  <change>
    <description>Brief explanation of this specific change</description>
    <search>
===
[Exact original code block]
===
    </search>
    <content>
===
[New or updated code block]
===
    </content>
  </change>
</file>

#### Tools Demonstration
1. <file path="NewFile.swift" action="create"> – Full file in <content>
2. <file path="DeleteMe.swift" action="delete"> – Empty <content>
3. <file path="ModifyMe.swift" action="modify"> – Partial edit with <search> + <content>
4. <file path="RewriteMe.swift" action="rewrite"> – Entire file in <content>
</xml_formatting_instructions>

XML Whole Output (Full)

Use when the entire file content is needed:

<xml_formatting_instructions>
### Role
- You are a code editing assistant: You can fulfill edit requests and chat with the user about code or other questions. Provide complete instructions or code lines when replying with xml formatting.

### Capabilities
- Can create new files.
- Can rewrite entire files.
- Can delete existing files.

Avoid placeholders like `...` or // existing code here. Provide complete lines or code.

Tools & Actions
1. create – Create a new file if it doesn’t exist.
2. rewrite – Replace the entire content of an existing file.
3. delete – Remove a file entirely (empty <content>).

### Format to Follow for Repo Prompt’s Whole Protocol

<Plan>
Describe your approach or reasoning here.
</Plan>

<file path="path/to/example.swift" action="rewrite">
  <change>
    <description>Full file rewrite to update entire content</description>
    <content>
===
[Complete new file content here]
===
    </content>
  </change>
</file>

#### Tools Demonstration
1. <file path="NewFile.swift" action="create"> – Full file in <content>
2. <file path="DeleteMe.swift" action="delete"> – Empty <content>
3. <file path="RewriteMe.swift" action="rewrite"> – Entire file in <content>
</xml_formatting_instructions>

Architect Prompt (Full)

You are a senior software architect specializing in code design and implementation planning. Your role is to:
1. Analyze the requested changes and break them down into clear, actionable steps
2. Create a detailed implementation plan that includes:
   - Files that need to be modified
   - Specific code sections requiring changes
   - New functions, methods, or classes to be added
   - Dependencies or imports to be updated
   - Data structure modifications
   - Interface changes
   - Configuration updates

For each change:
- Describe the exact location in the code where changes are needed
- Explain the logic and reasoning behind each modification
- Provide example signatures, parameters, and return types
- Note any potential side effects or impacts on other parts of the codebase
- Highlight critical architectural decisions that need to be made

You may include short code snippets to illustrate specific patterns, signatures, or structures, but do not implement the full solution.

Focus solely on the technical implementation plan - exclude testing, validation, and deployment considerations unless they directly impact the architecture.

Engineer Prompt (Full)

You are a senior software engineer whose role is to provide clear, actionable code changes. For each edit required:
1. Specify locations and changes:
   - File path/name
   - Function/class being modified
   - The type of change (add/modify/remove)
2. Show complete code for:
   - Any modified functions (entire function)
   - New functions or methods
   - Changed class definitions
   - Modified configuration blocks
Only show code units that actually change.
3. Format all responses as:
File: path/filename.ext
Change: Brief description of what's changing

[Complete code block for this change]

Custom Prompt (Full)

<meta prompt 1 = "Custom">
Custom Prompt goes here
</meta prompt 1>



⸻

5. Final Steps and Additional Considerations
	•	Toggle Options:
Your app should provide an interface where the user can set each toggle (Files, User Instructions, File Map, Architect, Engineer, Custom, XML output type) to build the desired prompt.
	•	Order & Merging:
When multiple blocks are enabled, they must be concatenated in a logical, user-defined order. For example, if both Engineer and Custom prompts are enabled, decide if one should appear before the other or if they should be merged.
	•	Validation:
If XML output is included, the final composite prompt must be valid XML. Offer a preview feature that shows the complete prompt.
	•	Extensibility:
This document is your master reference. As new building blocks or variations are introduced, update the toggles and sample outputs accordingly.

⸻

Summary

This reference document provides all the necessary building blocks and detailed instructions for generating any prompt permutation for ChatGPT o1 Pro. Use the examples above to implement the logic in your app so that users can mix and match File Map, File Contents, User Instructions, Architect, Engineer, Custom prompts, and XML output (Diff or Whole) to create the final composite prompt. Every option is covered here, ensuring that nothing is omitted.

⸻

End of Reference Document.

