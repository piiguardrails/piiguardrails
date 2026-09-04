"""
Enterprise PII Guardrail - LangChain Custom Transform Example
Demonstrates how to integrate PII Guardrail as a LangChain Runnable or Pipeline Transformer.
"""
import requests
from typing import Dict, Any

class PIIGuardrailTransformer:
    def __init__(self, endpoint: str = "http://localhost:8000", api_key: str = "your-api-key"):
        self.endpoint = endpoint.rstrip("/")
        self.headers = {"X-API-Key": api_key, "Content-Type": "application/json"}

    def mask(self, text: str) -> Dict[str, Any]:
        resp = requests.post(f"{self.endpoint}/mask", json={"text": text}, headers=self.headers)
        resp.raise_for_status()
        return resp.json()

    def unmask(self, text: str, mapping: Dict[str, str]) -> str:
        resp = requests.post(f"{self.endpoint}/unmask", json={"text": text, "mapping": mapping}, headers=self.headers)
        resp.raise_for_status()
        return resp.json().get("unmasked_text", text)

# Example chaining pattern (LCEL):
# guardrail = PIIGuardrailTransformer(api_key="...")
#
# def preprocess(input_dict):
#     masked = guardrail.mask(input_dict["query"])
#     return {"prompt": masked["masked_text"], "vault": masked["mapping"]}
#
# def postprocess(output_dict):
#     return guardrail.unmask(output_dict["llm_output"], output_dict["vault"])
