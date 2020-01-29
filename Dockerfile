FROM ocaml/opam2:debian-10-ocaml-4.08

RUN sudo mkdir /app
WORKDIR /app
ADD . /app/

RUN sudo apt-get update
RUN sudo apt-get install m4 freeglut3-dev libglu1-mesa-dev mesa-common-dev -y

RUN opam install lablgl obuild core
