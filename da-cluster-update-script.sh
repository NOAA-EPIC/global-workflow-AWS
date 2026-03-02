#!/bin/bash
cd /root/.spack
mv packages.yaml packages.yaml.bak
cd /opt
cd spack-stack
. ./setup.sh
cd /opt/spack-stack/envs/ue-oneapi-2024.2.1
spack env activate -p .
spack install --add grib-util%oneapi@2024.2.1@1.4.0
spack install --add prod-util%oneapi@2024.2.1@2.1.1
spack install --add cdo%oneapi@2024.2.1@2.3.0
spack module lmod refresh -y
spack stack setup-meta-modules
spack env deactivate
