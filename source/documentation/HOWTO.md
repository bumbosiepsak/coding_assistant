# User interaction

## Provisioning
The host system needs to be prepared according to this section.

You need the following dependencies to be installed on the (host) machine:
- Docker
- Docker Compose
- Docker Buildx

Please reference and/or launch the [provision_linux_x86_64.sh](provision_linux_x86_64.sh) in order
to prepare your machine, if applicable.

## Building and running
This section describes running the project.

### Downloading models
You need to download models first.

This has been separated from regular running for the sake of better control
and due to good reliability of the `huggingface_cli` tool (comparing to other methods).

Run: 
``` bash
cd <project root>

./download_model.sh small # Will download the small "coding assistant" model
```

and/or:

``` bash
cd <project root>

./download_model.sh full # Will download the full "coding assistant" model
```

### Running

In order to build and run the project, invoke:
``` bash
cd <project root>

./run.sh small # Will run a small demo with a small conversational model
```

and/or:
``` bash
cd <project root>

./run.sh full # Will run a full demo with a proper coding assistant model
```

This will build and run a Docker Compose project (combined for the sake of demo simplicity).

### Terminating

In order to stop the project, invoke:

``` bash
cd <project root>

./stop.sh
```

## Testing
This section describes testing the project.

### Preconditions

The application built, up and running. Can be verified with the `docker ps --all` command, which should show:

``` bash
CONTAINER ID   IMAGE                                                 COMMAND                  CREATED         STATUS                   PORTS                                       NAMES
e94409e833b6   coding_assistant-linux_x86_64:latest                  "/bin/bash -o errexi…"   3 minutes ago   Up 3 minutes (healthy)   0.0.0.0:7860->7860/tcp, :::7860->7860/tcp   coding_assistant
322e5aa61db4   ghcr.io/huggingface/text-generation-inference:1.4.5   "text-generation-lau…"   3 minutes ago   Up 3 minutes             127.0.0.1:8080->80/tcp                      text_generation_inference
```

### Manual

Go to: `http://localhost:7860` and use the user interface. Happy chatting!
