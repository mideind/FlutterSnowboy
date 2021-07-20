/*
 * Copyright (C) 2021 Miðeind ehf.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

package is.mideind.flutter_snowboy;

import ai.kitt.snowboy.SnowboyDetect;


public class Detector {
    // Load compiled Snowboy shared object
    static {
        System.loadLibrary("snowboy-detect-android");
    }

    private static final String TAG = RecordingThread.class.getSimpleName();
    private final Handler handler;
    private final SnowboyDetect detector;
    private Thread thread;
    private boolean shouldContinue;

    public Detector(Handler handler, String commonPath, String modelPath,
                           String sensitivity, double audioGain, boolean applyFrontend) {
        this.handler = handler;
        this.detector = new SnowboyDetect(commonPath, modelPath);
        this.detector.SetSensitivity(sensitivity);
        this.detector.SetAudioGain((float)audioGain);
        this.detector.ApplyFrontend(applyFrontend);
    }

    public void detect(byte[] audioData) {
        // Feed data into SnowboyDetect
        // Snowboy hotword detection.
        int result = detector.RunDetection(audioData, audioData.length);

        if (result == -2) {
            // post a higher CPU usage:
            // sendMessage(MsgEnum.MSG_VAD_NOSPEECH, null);
        } else if (result == -1) {
            sendMessage(MsgEnum.MSG_ERROR, "Unknown Detection Error");
        } else if (result == 0) {
            // post a higher CPU usage:
            // sendMessage(MsgEnum.MSG_VAD_SPEECH, null);
        } else if (result > 0) {
            sendMessage(MsgEnum.MSG_ACTIVE, null);
            Log.i("Snowboy: ", "Hotword " + Integer.toString(result) + " detected!");
        }
    }

    private void sendMessage(MsgEnum what, Object obj) {
        if (null != handler) {
            Message msg = handler.obtainMessage(what.ordinal(), obj);
            handler.sendMessage(msg);
        }
    }

}