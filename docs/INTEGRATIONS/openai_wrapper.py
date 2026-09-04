"""
Enterprise PII Guardrail - OpenAI Drop-in Wrapper Example
Demonstrates how to automatically scrub prompts before sending them to OpenAI,
and automatically restore masked tokens on completion.
"""
import requests
from typing import Optional, List, Dict, Any

class GuardedOpenAI:
    def __init__(
        self, 
        guardrail_url: str = "http://localhost:8000", 
        guardrail_api_key: str = "your-guardrail-api-key",
        openai_client: Optional[Any] = None
    ):
        self.guardrail_url = guardrail_url.rstrip("/")
        self.headers = {
            "X-API-Key": guardrail_api_key,
            "Content-Type": "application/json"
        }
        
        if openai_client is None:
            from openai import OpenAI
            self.openai = OpenAI()
        else:
            self.openai = openai_client

    def mask(self, text: str) -> Dict[str, Any]:
        """Scrubs PII from prompt text."""
        res = requests.post(
            f"{self.guardrail_url}/mask",
            json={"text": text},
            headers=self.headers,
            timeout=5.0
        )
        res.raise_for_status()
        return res.json()

    def unmask(self, text: str, mapping: Dict[str, str]) -> str:
        """Restores PII tokens in LLM completion."""
        res = requests.post(
            f"{self.guardrail_url}/unmask",
            json={"text": text, "mapping": mapping},
            headers=self.headers,
            timeout=5.0
        )
        res.raise_for_status()
        return res.json().get("unmasked_text", text)

    def chat_completion(
        self, 
        model: str, 
        messages: List[Dict[str, str]], 
        **kwargs
    ) -> Dict[str, Any]:
        """
        Interception wrapper:
        1. Masks user prompt(s).
        2. Sends safe prompt to OpenAI.
        3. Unmasks LLM response using deterministic token vault.
        """
        combined_mapping = {}
        sanitized_messages = []

        for msg in messages:
            if msg.get("role") in ("user", "system"):
                mask_result = self.mask(msg["content"])
                combined_mapping.update(mask_result.get("mapping", {}))
                sanitized_messages.append({
                    "role": msg["role"],
                    "content": mask_result["masked_text"]
                })
            else:
                sanitized_messages.append(msg)

        # Send sanitized prompt to OpenAI (zero PII leaves your server)
        completion = self.openai.chat.completions.create(
            model=model,
            messages=sanitized_messages,
            **kwargs
        )

        raw_llm_reply = completion.choices[0].message.content
        
        # Restore entity tokens back to real values for authorized consumer
        restored_reply = self.unmask(raw_llm_reply, combined_mapping)
        
        return {
            "completion": completion,
            "safe_prompt_sent_to_llm": sanitized_messages[-1]["content"],
            "raw_llm_reply": raw_llm_reply,
            "final_unmasked_reply": restored_reply,
            "tokens_intercepted": len(combined_mapping)
        }

if __name__ == "__main__":
    # Example usage:
    # client = GuardedOpenAI(guardrail_api_key="sk-live-...")
    # result = client.chat_completion(
    #     model="gpt-4o-mini",
    #     messages=[{"role": "user", "content": "Schedule appointment for Alice Smith (SSN: 123-45-6789)."}]
    # )
    # print(result["final_unmasked_reply"])
    pass
