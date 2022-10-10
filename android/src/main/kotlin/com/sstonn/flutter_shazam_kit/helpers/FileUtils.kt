package com.sstonn.flutter_shazam_kit.helpers

class FileUtils {
    companion object{
        fun supportedAudioExtensions(): Array<String>{
            return arrayOf("mp3","wav","3gpp","amr","aac","m4a","ogg")
        }
    }
}