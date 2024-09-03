FROM ubuntu:22.04

LABEL version="1.0.1"
LABEL repository="https://github.com/StanislawHornaGitHub/SelfHostedRunner"

ARG RUNNER_VERSION="2.317.0"
ARG PWSH_VERSION="7.4.3"

ENV ACCESS_TOKEN="xxx"
ENV GITHUB_OBJECT="xxx"
ENV LABELS=""


# update the base packages
RUN apt-get update -y \
    && apt-get upgrade -y

# install useful packages
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    curl wget jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip

WORKDIR /usr/bin/actions-runner


###################################
#  Install the Github SelfRunner  #
###################################
RUN mkdir actions-runner \
    && cd actions-runner 
RUN wget -q https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz
RUN tar -xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz 
RUN /usr/bin/actions-runner/bin/installdependencies.sh


####################################
#  Install the PowerShell package  #
####################################
RUN wget -q "https://github.com/PowerShell/PowerShell/releases/download/v$PWSH_VERSION/powershell_$PWSH_VERSION-1.deb_amd64.deb"
RUN dpkg -i "powershell_$PWSH_VERSION-1.deb_amd64.deb"
RUN apt-get install -f
RUN rm "powershell_$PWSH_VERSION-1.deb_amd64.deb"


# copy over the start.sh script
COPY ./start.sh /usr/bin/actions-runner/start.sh

CMD ["./start.sh"]
