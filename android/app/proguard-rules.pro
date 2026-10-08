# R8 rules for the release build. Flutter and most plugins ship their own
# consumer rules; these cover what they do not.

# Local notifications: the plugin reads its saved schedule back with reflection
# (Gson) when the phone restarts, so its model classes must keep their names.
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Keep line numbers in crash reports (Play Console vitals), hiding file names.
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
