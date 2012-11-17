# Used to quick start builds with ros-catkin on linux systems.

PWD=`pwd`
CMAKE_INSTALL_PREFIX=${PWD}/install

sources:
	rm -rf src
	mkdir -p src
	cd src; rosws init --catkin
	cd src; rosws merge https://raw.github.com/stonier/ecl_tools/master/rosinstall/ecl_groovy.rosinstall
	cd src; rosws update

configure: clean
	mkdir -p build
	mkdir -p install
	cd build; cmake -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} ../src

build:
	cd build; make -j5

install:
	cd build; make install

clean:
	rm -rf build
	rm -rf install

.PHONY: sources configure build install clean
