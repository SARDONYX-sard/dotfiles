from os import system


system('\
pip install autopep8 \
flake8 \
codespell \
pip-review \
pipx \
poetry \
fprettify \
')

answer = input('Do you install big size libraries? (y/n)')

if answer == 'y':
    system('\
pip install cython \
notebook \
selenium \
')
