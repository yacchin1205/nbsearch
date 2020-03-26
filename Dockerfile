FROM niicloudoperation/notebook

USER root

# Install MongoDB
RUN apt-get update && apt-get install -yq supervisor uuid-runtime gnupg curl \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5 \
    && echo "deb http://repo.mongodb.org/apt/debian jessie/mongodb-org/3.6 main" | tee /etc/apt/sources.list.d/mongodb-org-3.6.list \
    && apt-get update && apt-get install -yq mongodb-org \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && chown $NB_USER -R /var/log/mongodb /var/lib/mongodb

COPY . /tmp/nbsearch
RUN pip install /tmp/nbsearch jupyter_nbextensions_configurator
RUN mkdir -p /usr/local/bin/before-notebook.d && \
    cp /tmp/nbsearch/example/*.sh /usr/local/bin/before-notebook.d/ && \
    chmod +x /usr/local/bin/before-notebook.d/*.sh

USER $NB_UID

RUN mkdir -p /home/$NB_USER/.nbsearch && \
    cp /tmp/nbsearch/example/config_*.py /home/$NB_USER/.nbsearch/

RUN mkdir /home/$NB_USER/.nbsearch/conf.d && \
    cp /tmp/nbsearch/example/supervisor.conf /home/$NB_USER/.nbsearch/supervisor.conf

RUN jupyter nbextensions_configurator enable --user && \
    jupyter nbextension install --py --user nbsearch && \
    jupyter serverextension enable --py --user nbsearch && \
    jupyter nbextension enable --py --user nbsearch && \
    jupyter nbextension enable --py --user lc_notebook_diff
