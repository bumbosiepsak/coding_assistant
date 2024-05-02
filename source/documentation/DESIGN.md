# Design
This file describes the design and its rationale.

## Design details

This solution utilises three main components:
- model downloading based on `huggingface_cli` (https://huggingface.co/spaces/HuggingFaceH4/starchat-playground)
- LLM model serving and Web user interface based on `oobabooga/text-generation-webui` (https://github.com/oobabooga/text-generation-webui)

## Implementation details
All services have been placed in Docker containers.

Building is being done with `Docker Buildx` in order to utilise state-of-the-art Docker features (caching, volumes, syntax).

Running is being done with `Docker Compose` in order to manage service sets "the Docker way".

Small BASH glue logic has been added in order to manipulate the project. Typically I'd use a more elaborate,
Python-based glue logic (I'm happy to share my past solutions). I decided to use simple BASH in order to keep this
part of the project small (so that the core, LLM part is not being overshadowed).

Models are being downloaded to the shared volume (`volumes/models/model_cache` on the host machine) and persist service restarts.

Configuration is being done via the Docker Compose environment file (`source/containers/docker-compose-service.env`)
and can be overridden with shell environment variables.

I'm running `oobabooga/text-generation-webui` in the CPU mode due to having no graphics card.
I didn't code a CUDA-based solution due to testing inability.

This solution still implements runtime selection of the mode. Necessary packages and glue logic is being containerised 
by adding extra variants in the `source/containers/images/coding_assistant/linux_x86_64/variants` folder (e.g. `cuda`).

The unfortunate part is that I have too little RAM for the full, `HuggingFaceH4/starchat-beta` model and the service
gets killed with SIGKILL by the Linux "out of memory" handler. Apologies for that. I'm hoping, that your hardware allows
for running this demo.

## Other considerations

Other solutions for running an LLM model exist, e.g.:
1. `Gradio` + `text-generation-inference` - I implemented it on the second branch
2. `LM Studio` (https://lmstudio.ai/) - looks like a neat, "all in one" desktop solution. I didn't take this approach, as it would show little coding skills
3. `HuggingChat Chat UI` + `text-generation-inference` (https://huggingface.co/spaces/huggingchat/chat-ui) - this is a more versatile replacement for the Gradio-based solution
