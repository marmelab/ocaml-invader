FROM ocaml/opam:debian-10_ocaml-4.05.0_flambda

RUN sudo mkdir /app
WORKDIR /app
ADD . /app/

RUN sudo apt-get update

RUN opam install obuild core
RUN opam depext lablgl
