from openai import OpenAI
import os
import time
import httpcore
import httpx
import openai

# Modify OpenAI's API key and API base to use vLLM's API server.
openai_api_key = "EMPTY"
openai_api_base = "http://localhost:8000/v1"
client = OpenAI(
    api_key=openai_api_key,
    base_url=openai_api_base,
)

test_prompts = [
    "In a few sentences, describe the theory of relativity.",
    "Write a small Python script for calling a model named `./gemma-4-31B-it` using the `openai` Python library.",
    "Describe the difference between GPT and LLAMA AI models.",
]
completions = []

while True:
    try:
        model = client.models.list().data[0].id
        start = time.time()
        for test_prompt in test_prompts:
            completion = client.chat.completions.create(
                model=f"{model}",
                messages=[
                    {"role": "user", "content": test_prompt },
                ],
                stream=False
            )
            print("Completion result:", completion, flush=True)
            print("Time since beginning:", time.time() - start, flush=True)
            completions.append(completion)
    except httpcore.ConnectError:
        print("vllm server is not ready. Waiting 10 seconds...", flush=True)
        time.sleep(10)
    except httpx.ConnectError:
        print("vllm server is not ready. Waiting 10 seconds...", flush=True)
        time.sleep(10)
    except openai.APIConnectionError:
        print("vllm server is not ready. Waiting 10 seconds...", flush=True)
        time.sleep(10)
    else:
        break
print("Completion result:", [completion for completion in completions], flush=True)
