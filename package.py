name = "bm_cmake_modules"

authors = ['malbertsson']


def commands():
    appendenv('CMAKE_MODULE_PATH', '{root}/cmake')
