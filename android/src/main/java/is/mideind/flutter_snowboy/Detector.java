/*
 * Copyright (C) 2021-2022 Miðeind ehf.
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

import ai.kitt.snowboy.Constants;
import ai.kitt.snowboy.MsgEnum;
import ai.kitt.snowboy.SnowboyDetect;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;

import android.os.Handler;
import android.os.Message;
import android.util.Log;

public class Detector {
    // Load compiled Snowboy shared object
    static {
        System.loadLibrary("snowboy-detect-android");
    }

    private final Handler handler;
    private final SnowboyDetect snowboy;

    public Detector(Handler handler, String commonPath, String modelPath,
            String sensitivity, double audioGain, boolean applyFrontend) {

        // Create and configure SnowboyDetect object
        this.snowboy = new SnowboyDetect(commonPath, modelPath);
        this.snowboy.SetSensitivity(sensitivity);
        this.snowboy.SetAudioGain((float) audioGain);
        this.snowboy.ApplyFrontend(applyFrontend);

        this.handler = handler;
    }

    public void detect(byte[] audioBuffer) {
        // Convert data to 16-bit shorts and feed into Snowboy detection function
        short[] audioData = new short[audioBuffer.length / 2];
        ByteBuffer.wrap(audioBuffer).order(ByteOrder.LITTLE_ENDIAN).asShortBuffer().get(audioData);
        int result = this.snowboy.RunDetection(audioData, audioData.length);

        // Process result from Snowboy detection fn
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
            // Log.i("Snowboy: ", "Hotword " + Integer.toString(result) + " detected!");
        }
    }

    private void sendMessage(MsgEnum what, Object obj) {
        if (handler != null) {
            Message msg = handler.obtainMessage(what.ordinal(), obj);
            handler.sendMessage(msg);
        }
    }

}