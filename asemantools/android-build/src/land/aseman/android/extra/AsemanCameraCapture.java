/*
    Copyright (C) 2014 Aseman
    http://aseman.co

    This project is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This project is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

package land.aseman.android.extra;

import land.aseman.android.AsemanApplication;
import land.aseman.android.AsemanActivity;
import land.aseman.android.AsemanService;

import android.os.Bundle;
import android.content.Context;
import android.content.ContentResolver;
import android.provider.Settings;
import android.util.Log;
import android.view.SurfaceView;
import android.view.SurfaceHolder;
import android.view.SurfaceHolder.Callback;
import android.view.WindowManager;
import android.graphics.PixelFormat;
import android.hardware.Camera;
import android.hardware.Camera.PictureCallback;
import android.os.Environment;
import java.util.HashMap;
import java.io.IOException;
import java.io.File;
import java.io.FileOutputStream;
import java.util.List;
import java.util.Locale;
import java.util.Date;
import java.lang.Runnable;
import java.text.SimpleDateFormat;
import android.os.Handler;

public class AsemanCameraCapture
{
    private static final String TAG = "AsemanCameraCapture";

    public native void _imageCaptured(int id, String path);

    public void capture(final int id, final String path, final boolean frontCamera) {
        Context context;
        context = AsemanApplication.getAppContext();

        Handler mainHandler = new Handler(context.getMainLooper());
        Runnable myRunnable = new Runnable() {
            @Override
            public void run() {
                try {
                    takePhoto(id, path,
                              frontCamera? Camera.CameraInfo.CAMERA_FACING_FRONT :
                                           Camera.CameraInfo.CAMERA_FACING_BACK);
                } catch (Exception e) {
                    _imageCaptured(id, "");
                }
            }
        };
        mainHandler.post(myRunnable);
    }

    private void takePhoto(final int actionId, final String path, final int cameraType) {
        Context context;
        context = AsemanApplication.getAppContext();

        final SurfaceView preview = new SurfaceView(context);
        SurfaceHolder holder = preview.getHolder();
        // deprecated setting, but required on Android versions prior to 3.0
        holder.setType(SurfaceHolder.SURFACE_TYPE_PUSH_BUFFERS);

        holder.addCallback(new Callback() {
            @Override
            //The preview must happen at or after this point or takePicture fails
            public void surfaceCreated(SurfaceHolder holder) {
                Log.d(TAG, "Surface created");

                Camera camera = null;

                try {
                    camera = openCamera(cameraType);
                    if(camera == null) {
                        _imageCaptured(actionId, "");
                        return;
                    }

                    Log.d(TAG, "Opened camera");

                    try {
                        camera.setPreviewDisplay(holder);
                    } catch (IOException e) {
                        throw new RuntimeException(e);
                    }

                    camera.startPreview();
                    Log.d(TAG, "Started preview");

                    camera.takePicture(null, null, new PictureCallback() {

                        @Override
                        public void onPictureTaken(byte[] data, Camera camera) {
                            Log.d(TAG, "Took picture");
                            savePicture(data, path);
                            camera.release();
                            _imageCaptured(actionId, path);
                        }
                    });
                } catch (Exception e) {
                    if (camera != null)
                        camera.release();
                    _imageCaptured(actionId, "");
                    throw new RuntimeException(e);
                }
            }

            @Override public void surfaceDestroyed(SurfaceHolder holder) {}
            @Override public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {}
        });

        WindowManager wm = (WindowManager)context.getSystemService(Context.WINDOW_SERVICE);
        WindowManager.LayoutParams params = new WindowManager.LayoutParams(
                1, 1, //Must be at least 1x1
                WindowManager.LayoutParams.TYPE_SYSTEM_OVERLAY,
                0,
                //Don't know if this is a safe default
                PixelFormat.UNKNOWN);

        //Don't set the preview visibility to GONE or INVISIBLE
        wm.addView(preview, params);
    }

    /** null if unable to save the file */
    public boolean savePicture(byte[] data, String filePath) {
        try {
            File pictureFile = new File(filePath);

            FileOutputStream fos = new FileOutputStream(pictureFile);
            fos.write(data);
            fos.close();

            return true;
        } catch (Exception e) {
            return false;
        }
    }

    private Camera openCamera(final int type) {
        int cameraCount = 0;
        Camera cam = null;
        Camera.CameraInfo cameraInfo = new Camera.CameraInfo();
        cameraCount = Camera.getNumberOfCameras();
        for (int camIdx = 0; camIdx < cameraCount; camIdx++) {
            Camera.getCameraInfo(camIdx, cameraInfo);
            if (cameraInfo.facing == type) {
                try {
                    cam = Camera.open(camIdx);
                } catch (RuntimeException e) {
                    Log.e(TAG, "Camera failed to open: " + e.getLocalizedMessage());
                }
            }
        }

        return cam;
    }
}
