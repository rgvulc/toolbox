FROM debian:trixie-slim AS base

# Ensure that if any of the curl commands fail, the build fails
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

###############################
##                           ##
## COMMON INSTALLATION SETUP ##
##                           ##
###############################

RUN apt-get update \
&& apt-get install -y --no-install-recommends ca-certificates curl bash git zstd \
&& rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash rgvulc
USER rgvulc
WORKDIR /home/rgvulc

ENV PATH="/home/rgvulc/.local/bin:${PATH}"

###############################
##                           ##
## IMAGE-SPECIFIC STAGES     ##
##                           ##
###############################

FROM base AS claude
RUN curl -fsSL https://claude.ai/install.sh | bash
WORKDIR /workspace
ENTRYPOINT ["claude"]


FROM base AS codex
ENV CODEX_NON_INTERACTIVE=1
RUN curl -fsSL https://chatgpt.com/codex/install.sh | sh
WORKDIR /workspace
ENTRYPOINT ["codex"]


FROM base AS ollama
USER root 
RUN curl -fsSL https://ollama.com/install.sh | sh
USER rgvulc
EXPOSE 11434 
ENTRYPOINT ["ollama"]
CMD ["serve"]


FROM base AS pandoc
USER root
RUN apt-get update \
&& apt-get install -y --no-install-recommends \
    pandoc \
    texlive-latex-base \
    texlive-latex-recommended \
    texlive-latex-extra \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    texlive-xetex \
    texlive-plain-generic \
    lmodern \
    fontconfig \
&& rm -rf /var/lib/apt/lists/*
USER rgvulc
WORKDIR /data
ENTRYPOINT ["pandoc"]
CMD ["--help"]