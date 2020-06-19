FROM jupyter/datascience-notebook
SHELL ["/bin/bash", "-c"]

USER root
RUN apt-get update && apt-get install -y file
RUN mkdir -p ~/source/mecab

WORKDIR /home/jovyan/source/mecab
RUN wget 'https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7cENtOXlicTFaRUE' -O mecab-0.996.tar.gz
RUN tar zxvf mecab-0.996.tar.gz

WORKDIR /home/jovyan/source/mecab/mecab-0.996
RUN mkdir -p /opt/mecab
RUN ./configure --prefix=/opt/mecab --with-charset=utf8 --enable-utf8-only
RUN make
RUN make install
RUN echo "export PATH=/opt/mecab/bin:\$PATH" >> ~/.bashrc
RUN source ~/.bashrc
RUN mecab-config --libs-only-L | sudo tee /etc/ld.so.conf.d/mecab.conf
RUN ldconfig
RUN mkdir ~/source/mecab-ipadic

WORKDIR /home/jovyan/source/mecab-ipadic
RUN wget 'https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7MWVlSDBCSXZMTXM' -O mecab-ipadic-2.7.0-20070801.tar.gz
RUN tar zxvf mecab-ipadic-2.7.0-20070801.tar.gz

WORKDIR /home/jovyan/source/mecab-ipadic/mecab-ipadic-2.7.0-20070801
RUN ./configure --with-mecab-config=/opt/mecab/bin/mecab-config --with-charset=utf8
RUN make
RUN make install

WORKDIR /home/jovyan/source
RUN git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd.git
ENV PATH $PATH:/opt/mecab/bin
RUN mecab --version
RUN ./mecab-ipadic-neologd/bin/install-mecab-ipadic-neologd -n -y -p /opt/mecab/lib/mecab/dic/neologd

WORKDIR /home/jovyan
RUN rm -rf source

USER jovyan
RUN pip install --upgrade pip
RUN pip install mecab-python3
RUN pip install gensim

WORKDIR /home/jovyan
