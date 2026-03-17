#!/bin/bash
cd /root/.spack
mv packages.yaml packages.yaml.bak
tee /root/.spack/packages.yaml <<EOF
packages:
  gcc:
    externals:
    - spec: gcc@11.4.0 languages='c,c++,fortran'
      prefix: /usr
      extra_attributes:
        compilers:
          c: /usr/bin/gcc
          cxx: /usr/bin/g++
          fortran: /usr/bin/gfortran
EOF

cd /opt/spack-stack/envs

rm -rf ue-oneapi-2024.2.1

cd /opt/spack-stack

. ./setup.sh

spack stack create env --site linux.default --template unified-dev --name ue-oneapi-2024.2.1 --compiler oneapi

cd /opt/spack-stack/envs/ue-oneapi-2024.2.1
spack env activate -p .
spack compiler rm -a oneapi@2024.2.1
export ONEAPIPATH=`ls -d /opt/spack-stack/spack/opt/spack/linux-ubuntu22.04-*/gcc-11.4.0/intel-oneapi-compilers-2024.2.1-*`
spack compiler add `spack location -i intel-oneapi-compilers` $ONEAPIPATH/compiler/latest/bin/

tee /opt/spack-stack/envs/ue-oneapi-2024.2.1/spack.yaml <<EOF
# spack-stack hash: a417ddf
# spack hash: edd09cd2ae
spack:
  concretizer:
    unify: when_possible

  view: false
  include:
  - site
  - common

  definitions:
  - compilers:
    - '%oneapi'
  - packages:
    - global-workflow-env   ^esmf@=8.6.1 ^crtm@=3.1.1-build1
    - jedi-neptune-env      ^esmf@=8.8.0
    - jedi-ufs-env          ^esmf@=8.6.1
    - neptune-env           ^esmf@=8.8.0
    - neptune-python-env    ^esmf@=8.8.0
    - ufs-srw-app-env       ^esmf@=8.8.0 ^crtm@=3.1.1-build1
    - ufs-weather-model-env ^esmf@=8.8.0 ^crtm@=3.1.1-build1
    - crtm@2.4.0.1
    - mapl@2.53.4 ^esmf@8.8.0
    - esmf@=8.8.0 snapshot=none
  specs:
  - matrix:
    - [\$packages]
    - [\$compilers]
    exclude:
    # Don't build ai-env and jedi-tools-env with Intel or oneAPI,
    # some packages don't build (e.g., py-torch in ai-env doesn't
    # build with Intel, and there are constant problems concretizing
    # the environment
    - ai-env%intel
    - ai-env%oneapi
    - jedi-tools-env%intel
    - jedi-tools-env%oneapi
  - zlib@1.2.13
  packages:
    all:
      prefer: ['%oneapi']
      providers:
        mpi: [intel-oneapi-mpi]
  compilers:
  - compiler:
      spec: oneapi@=2024.2.1
      paths:
        cc: /opt/spack-stack/spack/opt/spack/linux-ubuntu22.04-sapphirerapids/gcc-11.4.0/intel-oneapi-compilers-2024.2.1-j3owv3rsoh7igqvwmvp7ez6i3ozeayvs/compiler/latest/bin/icx
        cxx: /opt/spack-stack/spack/opt/spack/linux-ubuntu22.04-sapphirerapids/gcc-11.4.0/intel-oneapi-compilers-2024.2.1-j3owv3rsoh7igqvwmvp7ez6i3ozeayvs/compiler/latest/bin/icpx
        f77: /opt/spack-stack/spack/opt/spack/linux-ubuntu22.04-sapphirerapids/gcc-11.4.0/intel-oneapi-compilers-2024.2.1-j3owv3rsoh7igqvwmvp7ez6i3ozeayvs/compiler/latest/bin/ifort
        fc: /opt/spack-stack/spack/opt/spack/linux-ubuntu22.04-sapphirerapids/gcc-11.4.0/intel-oneapi-compilers-2024.2.1-j3owv3rsoh7igqvwmvp7ez6i3ozeayvs/compiler/latest/bin/ifort
      flags: {}
      operating_system: ubuntu22.04
      target: x86_64
      modules: []
      environment: {}
      extra_rpaths: []
EOF

spack concretize 2>&1 | tee log.concretize
spack install --verbose --fail-fast --show-log-on-error --no-check-signature 2>&1 | tee log.install
spack install --add py-click@8.1.7
spack module lmod refresh -y
spack stack setup-meta-modules
spack env deactivate
