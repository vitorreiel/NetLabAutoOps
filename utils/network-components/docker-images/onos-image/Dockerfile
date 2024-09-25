# Use a imagem base do ONOS
FROM onosproject/onos:2.7-latest

# Variavel de ambiente
ENV ONOS=/root/onos

# Ativa aplicações necessárias 
RUN touch $ONOS/apps/org.onosproject.openflow-base/active \
    touch $ONOS/apps/org.onosproject.openflow-message/active \
    touch $ONOS/apps/org.onosproject.ofagent/active \
    touch $ONOS/apps/org.onosproject.openflow/active \
    touch $ONOS/apps/org.onosproject.workflow.ofoverlay/active \
    touch $ONOS/apps/org.onosproject.fwd/active

# Comando padrão para rodar o ONOS
CMD ["onos"]