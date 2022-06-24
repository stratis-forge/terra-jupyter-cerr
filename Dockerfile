FROM us.gcr.io/broad-dsp-gcr-public/terra-jupyter-base:latest

USER root

RUN apt-get update
RUN apt-get -y install curl wget nano libgraphicsmagick++1-dev libsuitesparse-dev libqrupdate1 libreadline7 libfftw3-3 libhdf5-100 libgl1 libglu1-mesa libgl2ps1.4 \
        libcurl4-gnutls-dev libarpack2 libopenblas-base git gnuplot libqt5gui5 libqt5core5a

RUN mkdir /content

RUN LOCATION=$(curl -s https://api.github.com/repos/cerr/octave-colab/releases/latest \
| awk -F\" '/browser_download_url/ { print $4 }') && curl -L -o /content/octavecolab.tar.gz $LOCATION
 
RUN cd /content && tar xzvf /content/octavecolab.tar.gz
RUN chmod -R 777 /content

USER jupyter
ENV OCTAVE_EXECUTABLE /content/octave/bin/octave-cli
ENV PATH /content/octave/bin/:$PATH

RUN cd /content && git clone https://github.com/cerr/CERR.git && cd /content/CERR && git checkout octave_dev

EXPOSE $JUPYTER_PORT
WORKDIR $HOME

RUN conda env list
RUN conda install -y -c conda-forge oct2py

# Note: this entrypoint is provided for running Jupyter independently of Leonardo.
# When Leonardo deploys this image onto a cluster, the entrypoint is overwritten to enable
# additional setup inside the container before execution.  Jupyter execution occurs when the
# init-actions.sh script uses 'docker exec' to call run-jupyter.sh.
ENTRYPOINT ["/opt/conda/bin/jupyter", "notebook"]
