from openai import OpenAI
from pydantic import BaseModel, Field
from typing import Literal
import json

with open("open_ai.txt", "r") as f:
    api_key = f.read().strip()
client = OpenAI(api_key=api_key)



def get_dermatology_assessment(disease: str, age: int, gender: str) -> dict:
    system_prompt = (
        f"You are an expert dermatologist API providing assessments for medical applications. "
        f"Analyze {disease} for a {age}-year-old {gender} patient. "
        f"Provide evidence-based, safe, and medically appropriate recommendations. "
        f"\n\n"
        f"You MUST respond with ONLY valid JSON in this exact format (no markdown, no extra text):\n"
        f'{{\n'
        f'  "disease_description": "A 1 sentence description",\n'
        f'  "severity_level": "High" or "Medium" or "Low",\n'
        f'  "immediate_action": "What to do right now. Extremely short 1 - 3 bullet points",\n'
        f'  "things_to_keep_in_mind": ["point 1", "point 2", "point 3"],\n'
        f'  "consult_doctor": "Yes" or "No",\n'
        f'  "consult_doctor_reasoning": "Brief explanation",\n'
        f'}}'
    )
    
    try:
        response = client.responses.create(
            model="gpt-5",
            instructions=system_prompt,
            input="Provide your complete dermatological assessment in JSON format.",
            tools=[{"type": "web_search"}],
            reasoning={"effort": "low"},
            service_tier="priority"
        )
        
        # Extract and clean the output
        output = response.output_text.strip()
        
        # Remove markdown code blocks if present
        if "```json" in output:
            output = output.split("```json")[1].split("```")[0].strip()
        elif "```" in output:
            output = output.split("```")[1].split("```")[0].strip()
        
        # Parse JSON
        result = json.loads(output)
        return result
        
    except json.JSONDecodeError as e:
        print(f"JSON parsing error: {e}")
        print(f"Raw output: {response.output_text}")
        return None
    except Exception as e:
        print(f"Error: {e}")
        return None

# Example usage
if __name__ == "__main__":
    disease = "eczema"
    age = 32
    gender = "male"
    
    assessment = get_dermatology_assessment(disease, age, gender)
    
    if assessment:
        print(json.dumps(assessment, indent=2))
    else:
        print("Failed to get assessment")
