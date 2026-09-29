.PHONY: dev clean build-ios build-android

dev:
	flutter run

clean:
	flutter clean
	flutter pub get

build-ios:
	flutter build ipa

build-android:
	flutter build appbundle

deploy-iphone:
	flutter run --release