# Suppress warnings about GpuDelegateFactory$Options and GpuDelegateFactory$Options$GpuBackend
-dontwarn org.tensorflow.lite.gpu.GpuDelegateFactory$Options
-dontwarn org.tensorflow.lite.gpu.GpuDelegateFactory$Options$GpuBackend

# Keep TensorFlow Lite GPU and related delegate classes
-keep class org.tensorflow.lite.gpu.** { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory$Options { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegate$Options { *; }

# Keep the Flex delegate (if using it)
-keep class org.tensorflow.lite.select.** { *; }
-keep class org.tensorflow.lite.** { *; }

# Keep TensorFlow Lite Delegate
-keep class org.tensorflow.lite.Delegate { *; }

# Keep TensorFlow Lite GPU delegate factory class
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory { *; }
