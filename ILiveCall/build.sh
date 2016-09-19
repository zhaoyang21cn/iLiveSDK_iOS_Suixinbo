#build.sh

SDK=$compileEnv

#local run example:SDK=iphoneos5.0

XCODE_PATH=$XCODE_PATH$compileEnv

#local run example:XCODE_PATH=xcodebuild
$XCODE_PATH -target dailybuild -configuration DailyBuild clean -sdk $SDK

if [ -e  build/DailyBuild-iphoneos/*.ipa ] ;then

cd build/DailyBuild-iphoneos;

cd ..

rm -r *;

cd ..;

fi



#if [ -e  result ] ;then

#rm -r result;

#fi

#mkdir result


currentdate=`date +%Y%m%d`;
appname="ILiveCall_v${NumberVersion}_${currentdate}";
$XCODE_PATH -target dailybuild -configuration DailyBuild -sdk $SDK

cp build/DailyBuild-iphoneos/*.ipa result/${appname}.ipa

if ! [ $? = 0 ] ;then
exit 1
fi