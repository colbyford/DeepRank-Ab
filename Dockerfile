FROM pytorch/pytorch:2.0.1-cuda11.7-cudnn8-runtime

LABEL authors="Colby T. Ford <colby@tuple.xyz>"
ENV DEBIAN_FRONTEND noninteractive

## Install system requirements
RUN apt update && \
    apt-get install -y --reinstall \
        ca-certificates && \
    apt install -y \
        git \
        wget \
        libxml2 \
        libgl-dev \
        libgl1 \
        gcc \
        g++

## Set working directory
RUN mkdir -p /software/deeprank-ab
WORKDIR /software/deeprank-ab

## Clone DeepRank-Ab project
RUN git clone https://github.com/haddocking/DeepRank-Ab /software/deeprank-ab 

## Get weights
RUN mkdir -p /software/deeprank-ab/esm_weights && \
    wget https://dl.fbaipublicfiles.com/fair-esm/regression/esm2_t33_650M_UR50D-contact-regression.pt \
        -O /software/deeprank-ab/esm_weights/esm2_t33_650M_UR50D-contact-regression.pt && \
    wget https://dl.fbaipublicfiles.com/fair-esm/models/esm2_t33_650M_UR50D.pt \
        -O /software/deeprank-ab/esm_weights/esm2_t33_650M_UR50D.pt

## Create conda environment
# COPY environments/environment-gpu.yml /software/deeprank-ab/environments/environment-gpu.yml
RUN conda env create -f /software/deeprank-ab/environment-gpu.yml

## Install ANARCI
RUN conda install -n deeprank-ab -c bioconda anarci 

## Automatically activate conda environment
RUN echo "source activate deeprank-ab" >> /etc/profile.d/conda.sh && \
    echo "source /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate deeprank-ab" >> ~/.bashrc

## Default shell and command
SHELL ["/bin/bash", "-l", "-c"]
CMD ["/bin/bash"]