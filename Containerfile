FROM registry.ocp4.example.com:8443/redhattraining/podman-certificate-generator as certs
RUN sh ./gen_certificates.sh


FROM registry.ocp4.example.com:8443/ubi8/ubi
ENV TLS_PORT=8443 HTTP_PORT=8080 CERTS_PATH=/etc/pki/tls/private/certs
RUN dnf module install -y nodejs:16 && \
    groupadd -r student && useradd -r -m -g student student

COPY --from=certs --chown=student:student /app/*.pem /etc/pki/tls/private/certs/
COPY --chown=student:student . /app/
WORKDIR /app
RUN npm ci --omit=dev
USER student
ENTRYPOINT npm start
