#!/bin/bash

docker run -it -v "$(pwd):/owexec" openwhisk/swift3action bash -e -c "

if [ -z \"$1\" ] ; then
    echo 'Error: Missing action name'
    exit
fi

if [ -f \"/owexec/build/$1.zip\" ] ; then
    rm \"/owexec/build/$1.zip\"
fi

# echo 'Installing zip...'
# apt-get -qq install -y zip > /dev/null

echo 'Setting up build...'
cp \"/owexec/build/$1.swift\" /swift3Action/spm-build/main.swift
cat /swift3Action/epilogue.swift >> /swift3Action/spm-build/main.swift
echo '_run_main(mainFunction:main)' >> /swift3Action/spm-build/main.swift

echo 'Compiling $1...'
/swift3Action/spm-build/swiftbuildandlink.sh

echo 'Creating archive $1.zip...'
cd /swift3Action/spm-build
zip \"/owexec/build/$1.zip\" .build/release/Action

"
