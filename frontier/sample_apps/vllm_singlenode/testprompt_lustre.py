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
        # no need to specify model. It will pick the first one on the vllm server
        # by default.
        model = client.models.list().data[0].id
        completion = client.responses.create(model=model, 
                                      input="What is the Magellanic cloud? Use only two sentences.")
                                             

    except httpcore.ConnectError as e:
        print("vllm server is not ready. Waiting 10 seconds...", e, flush=True)
        time.sleep(10)
    except httpx.ConnectError as e :
        print("vllm server is not ready. Waiting 10 seconds...", e, flush=True)
        time.sleep(10)
    except openai.APIConnectionError as e :
        print("vllm server is not ready. Waiting 10 seconds...", e, flush=True)
        time.sleep(10)
    else:
        break
print("Completion result:", completion, flush=True)
#print("Completion result:", completion.output[0].content[0].text, flush=True)
