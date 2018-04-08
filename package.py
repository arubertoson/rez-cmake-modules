
name = "cmake_modules"

version = '0.0.1'

authors = ['malbertsson']

# requires = [
#     'cmake',
# ]

def commands():
    appendenv('CMAKE_MODULE_PATH', '{root}/cmake')
