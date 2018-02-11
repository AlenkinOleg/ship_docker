FROM oleg94/worker

RUN cd $SHIPSOFT; rm -rf ShipOpt; git clone https://github.com/AlenkinOleg/InnerOpt.git; mv InnerOpt ShipOpt

CMD ["bash"]
