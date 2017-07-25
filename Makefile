CC = xcodebuild
CCFLAGS = build

SIGNATURE = CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO

PROJECT_NAME = "Facts and Chicks.xcodeproj"
PROJECT = -project $(PROJECT_NAME)

PATH_RELEASE = "build/Facts and Chicks/Build/Products/Release/Facts and Chicks.app"
# PATH_DEBUG = "build/Facts and Chicks/Build/Products/Debug/Facts and Chicks.app"

all: release
	$(CC) clean
	rm -rf build

release:
	$(CC) $(CCFLAGS) $(SIGNATURE) $(PROJECT) -scheme "Facts and Chicks - Release"
	@[ -d $(PATH_RELEASE) ] && cp -R $(PATH_RELEASE) . || echo "Release has not been built correctly"

debug:
	$(CC) $(CCFLAGS) $(SIGNATURE) $(PROJECT) -scheme "Facts and Chicks - Debug"

clean:
	$(CC) clean
	rm -rf build
	rm -r *.app
