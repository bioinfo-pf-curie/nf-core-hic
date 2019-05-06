FROM nfcore/base
LABEL authors="Nicolas Servant" \
      description="Docker image containing all requirements for nf-core/hic pipeline"

## Install gcc for pip iced install
RUN apt-get update && apt-get install -y gcc g++ && apt-get clean -y

COPY environment.yml /
RUN conda env create -f /environment.yml && conda clean -a
ENV PATH /opt/conda/envs/nf-core-hic-1.0.0/bin:$PATH
