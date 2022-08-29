/*
 * Copyright (C) 2016-2020 KITT.AI
 * Modifications were made by Miðeind ehf. Copyright (C) 2021-2022
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

package ai.kitt.snowboy;

import android.content.Context;
import android.util.Log;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;

public class AppResCopy {
    private final static String TAG = AppResCopy.class.getSimpleName();

    public static void copyFilesFromAssets(Context context, String assetsSrcDir, String sdcardDstDir,
            boolean override) {
        try {
            String fileNames[] = context.getAssets().list(assetsSrcDir);
            Log.e(TAG, "fileNames.toString()");
            if (fileNames.length > 0) {
                Log.i(TAG, assetsSrcDir + " directory has " + fileNames.length + " files.\n");
                File dir = new File(sdcardDstDir);
                if (!dir.exists()) {
                    if (!dir.mkdirs()) {
                        Log.e(TAG, "mkdir failed: " + sdcardDstDir);
                        return;
                    } else {
                        Log.i(TAG, "mkdir ok: " + sdcardDstDir);
                    }
                } else {
                    Log.w(TAG, sdcardDstDir + " already exists! ");
                }
                for (String fileName : fileNames) {
                    copyFilesFromAssets(context, assetsSrcDir + "/" + fileName, sdcardDstDir + "/" + fileName,
                            override);
                }
            } else {
                Log.i(TAG, assetsSrcDir + " is file\n");
                File outFile = new File(sdcardDstDir);
                if (outFile.exists()) {
                    if (override) {
                        outFile.delete();
                        Log.e(TAG, "overriding file " + sdcardDstDir + "\n");
                    } else {
                        Log.e(TAG, "file " + sdcardDstDir + " already exists. No override.\n");
                        return;
                    }
                }
                InputStream is = context.getAssets().open(assetsSrcDir);
                FileOutputStream fos = new FileOutputStream(outFile);
                byte[] buffer = new byte[1024];
                int byteCount = 0;
                while ((byteCount = is.read(buffer)) != -1) {
                    fos.write(buffer, 0, byteCount);
                }
                fos.flush();
                is.close();
                fos.close();
                Log.i(TAG, "copy to " + sdcardDstDir + " ok!");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
