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

while True:
    try:
        completion = client.completions.create(model=f"./astrollama-2-7b-base_abstract",
                                      prompt="The Magellanic Cloud is a")
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
print("Completion result:", completion, flush=True)
